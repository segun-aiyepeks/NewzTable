const express = require('express');
const { requireDeviceId } = require('../middleware/deviceAuth');
const {
    initUser,
    getCurrentUser,
    updateTopics,
    updatePreferences
} = require('../controllers/userController');

const router = express.Router();

router.post('/init', initUser);
router.get('/me', requireDeviceId, getCurrentUser);
router.put('/topics', requireDeviceId, updateTopics);
router.put('/preferences', requireDeviceId, updatePreferences);

module.exports = router;