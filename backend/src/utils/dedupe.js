function normalizeTitle(title = '') {
    return title
        .toLowerCase()
        .normalize('NFKD')
        .replace(/\s+/g, ' ')
        .trim();
}

function tokenSet(normalized) {
    return new Set(normalized.split(' ').filter((w) => w.length > 2));
}

function jaccardSimilarity(a, b) {
    const setA = tokenSet(a);
    const setB = tokenSet(b);

    if (setA.size === 0 || setB.size === 0) return 0;

    let intersection = 0;
    for(const token of setA) {
        if(setB.has(token)) intersection += 1;
    }

    const union = setA.size + setB.size - intersection;
    return union === 0 ? 0 : intersection / union;
}

const SIMILARITY_THRESHOLD = 0.75;

function dedupeArticles(incoming, existingNormalizedTitles = []) {
    const seen = [...existingNormalizedTitles];
    const result = [];

    for (const article of incoming) {
        const normalized = normalizeTitle(article.title);
        const isDuplicate = seen.some(
            (existing) => existing === normalized || jaccardSimilarity(existing, normalized) >= SIMILARITY_THRESHOLD
        );
        if(!isDuplicate) {
            seen.push(normalized);
            result.push({ ...article, normalizedTitle: normalized});
        }
    }
    return result;
}

module.exports = { normalizeTitle, jaccardSimilarity, dedupeArticles};