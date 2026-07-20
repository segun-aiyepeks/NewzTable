const TOPICS = {
    technology: { label: 'Technology', category: 'technology'},
    business: { label: 'Business', category: 'business'},
    sports: { label: 'Sports', category: 'sports'},
    health: { label: 'Health', category: 'health'},
    entertainment: { label: 'Entertainment', category: 'entertainment'},
    science: { label: 'Science', category: 'science'},
    world: { label: 'World', category: 'world'},
    politics: { label: 'Politics', category: 'politics'},
    nigeria: { label: 'Nigeria', country: 'ng'},
    crypto: { label: 'Crypto', q: 'cryptocurrency OR bitcoin OR crypto'}
};

const TOPIC_KEYS = Object.keys(TOPICS);
const isValidTopic = (key) => TOPIC_KEYS.includes(key);

module.exports = {TOPICS, TOPIC_KEYS, isValidTopic };