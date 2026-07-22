const axios = require('axios');

const BASE_URL = 'https://newsdata.io/api/1/latest';

async function fetchFromNewsData(topicKey, topicConfig) {
    const apiKey = process.env.NEWSDATA_API_KEY;

    if(!apiKey) {
        console.warn('[newsdata] NEWSDATA_API_KEY not set - skipping fetch');
        return [];
    }

    const params = {
        apiKey: apiKey,
        language: 'en',
        ...(topicConfig.category && { category: topicConfig.category}),
        ...(topicConfig.country && { country: topicConfig.country}),
        ...(topicConfig.q && { q: topicConfig.q}) 
    };

    try {
        const { data } = await axios.get(BASE_URL, { params, timeout: 10_000});

        if(data.status !== 'success' && data.status !== 'ok') {
            console.error(`[newsdata] non-success status for topic = ${topicKey}`, data);
            return [];
        }

        const results = data.results || [];

        return results
            .filter((item) => item.title && item.link)
            .map((item) => ({
                externalId: `newsdata: ${item.article_id || item.link}`,
                provider: 'newsdata',
                topic: topicKey,
                title: item.title,
                description: item.description || '',
                content: item.co || item.description || '',
                url: item.link,
                imageUrl: item.image_url || null,
                sourceName: item.source_id || 'Unknown',
                language: item.language || 'en',
                publishedAt: item.pubDate ? new Date(item.pubDate) : new Date(),
            }));
    } catch (err) {
        console.error(`[newsdata] fetch failed for topic = ${topicKey}:`, err.message);
        return [];
    }
}

module.exports = { fetchFromNewsData};