const Bookmark = require('../models/Bookmark');
const Article = require('../models/Article');

async function listBookmarks(req, res, next) {
    try {
        const bookmarks = await Bookmark.find({ deviceId: req.deviceId })
            .sort({ createdAt: -1 })
            .populate('article')
            .lean();
        res.json(
            bookmarks.map((b) => ({
                bookmarkId: b._id,
                savedAt: b.createdAt,
                article: b.article
            }))
        );
    } catch (err) {
        next(err);
    }
}

async function addBookmark(req, res, next) {
    try{
        const { articleId } = req.body;

        if(!articleId) return res.status(400).json({ error: 'articleId is required' });

        const article = await Article.findById(articleId);
        if(!article) return res.status(404).json({ error: 'Article not found!' });

        const bookmark = await Bookmark.findOneAndUpdate(
            { deviceId: req.deviceId, article: articleId },
            { $setOnInsert: { deviceId: req.deviceId, article: articleId }},
            { upsert: true, new: true }
        );
        res.status(201).json(bookmark);
    } catch(err) {
        next(err);
    }
}

async function removeBookmark(req, res, next) {
    try {
        const result = await Bookmark.deleteOne({
            deviceId: req.deviceId,
            article: req.params.articleId
        });

        if (result.deletedCount === 0) {
            return res.status(404).json({ error: 'Bookmark not found!' });
        }
        res.status(204).send();
    } catch (err) {
        next(err);
    }
}

module.exports = { listBookmarks, addBookmark, removeBookmark };