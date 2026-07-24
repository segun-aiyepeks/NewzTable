const express = require('express');
const { requireDeviceId } = require('../middleware/deviceAuth');
const {
    listBookmarks,
    addBookmark,
    removeBookmark
} = require('../controllers/bookmarkController');

const router = express.Router();

router.use(requireDeviceId);

router.get('/', listBookmarks);
router.post('/', addBookmark);
router.delete('/', removeBookmark);

module.exports = router;