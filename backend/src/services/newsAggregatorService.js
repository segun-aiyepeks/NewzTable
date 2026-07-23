const Article = require('../models/Article');
const { TOPICS } = require('../constants/topics');
const { fetchFromNewsData } = require('./newsDataService');
const { fetchFromGuardian } = require('./guardianService');
const { dedupeArticles } = require( '../utils/dedupe');

const LOOKBACK_HOURS_FOR_DEDUPE = 48;

async function getExistingNormalizedTitles(topicKey) {
    const since = new Date(Date.now() - LOOKBACK_HOURS_FOR_DEDUPE *60 * 60 * 1000);

    const docs = await Article.find(
        { topic: topicKey, publishedAt: { $gte: since} },
        { normalizedTitle: 1, _id: 0 }
    ).lean();

    return docs.map((d) => d.normalizedTitle);
}

async function upsertArticles(articles) {
    if(articles.length === 0) return { upserted: 0};

    const ops = articles.map((article) => ({
        updateOne: {
            filter: { externalId: article.externalId },
            update: { $setOnInsert: article },
            upsert: true
        }
    }));

    const result = await Article.bulkWrite(ops, { ordered: false});
    return { upserted: result.upsertedCount || 0};
}

async function syncTopic(topicKey) {
    const config = TOPICS[topicKey];
    if (!config) throw new Error(`Unknown topic: ${topicKey}`);
    
    const [newsDataArticles, guardianArticles] = await Promise.all([
        fetchFromNewsData(topicKey, config),
        fetchFromGuardian(topicKey)
    ]);

    const combined = [...newsDataArticles, ...guardianArticles];
    if(combined.length === 0) return { topic: topicKey, fetched: 0, stored: 0};

    const existingTitles = await getExistingNormalizedTitles(topicKey);
    const deduped = dedupeArticles(combined, existingTitles);

    const { upserted } = await upsertArticles(deduped);

    return { topic: topicKey, fetched: combined.length, stored: upserted};
}

async function syncAllTopics() {
    const topicKeys = Object.keys(TOPICS);
    const results = [];

    for (const topicKey of topicKeys) {
        const result = await syncTopic(topicKey);
        results.push(result);
    }

    const totalStored = results.reduce((sum, r) => sum + r.stored, 0);
    console.log(`[aggregator] sync complete - ${totalStored} new articles stored`, results);
    return results;
}

module.exports = { syncTopic, syncAllTopics };