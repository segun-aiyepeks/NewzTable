const Article = require('../models/Article');
const User = require('../models/User');
const { TOPICS } = require('../constants/topics');

const DEFAULT_PAGE_SIZE = 20;
const AD_INTERVAL = 6;

function paginationParams(req) {
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const limit = Math.min(parseInt(req.query.limit, 10) || DEFAULT_PAGE_SIZE, 50);
    return { page, limit, skip: (page - 1) * limit };
}

function injectAdSlots(articles, page, limit) {
    const result = [];

    articles.forEach((article, idx) => {
        result.push({ type: 'article', data: article});

        const globalIndex = (page - 1) * limit + idx + 1;
        if (globalIndex % AD_INTERVAL === 0) {
            result.push({ type: 'ad', slotId: `feed-ad-${globalIndex} `});
        }
    });
    return result;
}

async function getFeed(req, res, next) {
    try {
        const user = await User.findOne({ deviceId: req.deviceId });

        if(!user) {
            return res.status(404).json({ error: 'User not initialized - call POST /api/users/init first' });
        }

        const { page, limit, skip } = paginationParams(req)

        // Optimization: "limit + 1" pattern to avoid expensive countDocuments() by default
        // We fetch one extra item to determine if there are more pages.
        const queryLimit = limit + 1;
        const skipTotal = req.query.skipTotal === 'true';

        const fetchPromise = Article.find({ topic: { $in: user.topics }})
            .sort({ publishedAt: -1 })
            .skip(skip)
            .limit(queryLimit)
            .lean();

        const [articlesResult, total] = await Promise.all([
            fetchPromise,
            skipTotal ? Promise.resolve(0) : Article.countDocuments({ topic: { $in: user.topics}})
        ]);

        let articles = articlesResult;

        const hasMore = articles.length > limit;
        if (hasMore) {
            articles.pop(); // Remove the extra item before returning
        }

        res.json({
            page,
            limit,
            total,
            hasMore,
            items: injectAdSlots(articles, page, limit),
        });

    } catch(err){
        next(err);
    }
}

async function searchArticles(req, res, next) {
    try {
        const { q } = req.query;

        if (!q || q.trim().length === 0) {
            return res.status(400).json({ })
        }

        const { page, limit, skip } = paginationParams(req);
        const regex = new RegExp(q.trim(), 'i');
        const filter = { $or: [{ title: regex }, { description: regex }]};

        // Optimization: "limit + 1" pattern to avoid expensive countDocuments()
        const queryLimit = limit + 1;
        const skipTotal = req.query.skipTotal === 'true';

        const fetchPromise = Article.find(filter).sort({ publishedAt: -1 }).skip(skip).limit(queryLimit).lean();

        const [articlesResult, total] = await Promise.all([
            fetchPromise,
            skipTotal ? Promise.resolve(0) : Article.countDocuments(filter)
        ]);

        let articles = articlesResult;

        const hasMore = articles.length > limit;
        if (hasMore) {
            articles.pop();
        }

        res.json({
            page,
            limit,
            total,
            hasMore,
            items: articles
        });
    } catch(err) {
        next(err);
    }
}

async function getArticleById(req, res, next) {
    try {
        const article = await Article.findById(req.params.id).lean();

        if (!article) return res.status(404).json({ error: 'Article not found'});

        const related = await Article.find({
            topic: article.topic,
            _id: { $ne: article._id },
        })
            .sort({ publishedAt: -1 })
            .limit(6)
            .lean();
        res.json({ article, related });
    } catch(err) {
        next(err);
    }
}
 function getTopics(req, res) {
    const list = Object.entries(TOPICS).map(([key, value]) => ({
        key,
        label: value.label
    }));
    res.json(list);
}

module.exports = { getFeed, searchArticles, getArticleById, getTopics };