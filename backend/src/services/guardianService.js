const axios = require('axios');

const BASE_URL = 'https://content.guardianapis.com/search';

const TOPIC_TO_SECTION = {
    technology: 'technology',
    business: 'business',
    sports: 'sport',
    health: 'soceity',
    entertainment: 'culture',
    science: 'science',
    world: 'world',
    politics: 'politics'
};

async function fetchFromGuardian(topicKey) {
    const apiKey = process.env.GUARDIAN_API_KEY;
    const section = TOPIC_TO_SECTION[topicKey];

    if(!apiKey || !section) return [];

    const params = {
        'api-key': apiKey,
        section,
        'show-fields': 'trailText, thumbnail, bodyText',
        'order-by': 'newest',
        'page-size': 20,
    };

    try {
        const { data } = await axios.get(BASE_URL, { params, timeout: 10_000});
        const results = data.response?.results || [];

        return results.map((item) => ({
            externalId: `guardian.${item.id}`,
            provider: 'guardian',
            topic: topicKey,
            title: item.webTitle,
            description: item.fields?.trailText || '',
            content: item.fields?.bodyText?.slice(0, 2000) || item.fields?.trailText || '',
            url: item.webUrl,
            imageUrl: item.fields?.thumbnail || null,
            sourceName: 'The Guardian',
            language: 'en',
            publishedAt: item.webPublicationDate ? new Date(item.webPublicationDate) : new Date(),
        }));
    } catch (err) {
        console.error(`[guardian] fetch failed for topic = ${topicKey}:`, err.message);
        return [];
    }
}

module.exports = { fetchFromGuardian };