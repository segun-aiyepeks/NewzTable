const express = require('express');
const { requireDeviceId } = require('../middleware/deviceAuth');
const {
    getFeed,
    searchArticles,
    getArticleById,
    getTopics
} = require('../controllers/articleController');

const router = express.Router();

router.get('/topics', getTopics);
router.get('/feed', requireDeviceId, getFeed);
router.get('/search', searchArticles);
router.get('/id', getArticleById);

module.exports = router;