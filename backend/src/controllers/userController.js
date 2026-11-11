const User = require('../models/User');
const { isValidTopic } = require('../constants/topics');

function validateTopics(topics) {
    if (!Array.isArray(topics) || topics.length === 0) {
        return 'topics must be a non-empty array';
    }
    if (!topics.every(isValidTopic)) {
        return 'topic contains an unknown topic key';
    }
    return null;
}

async function initUser(req, res, next) {
    try{
        const { deviceId, topics } = req.body;

        if (!deviceId) return res.status(400).json({ error: 'deviceId is required' });

        const topicsError = validateTopics(topics);
        if (topicsError) return res.status(400).json({ error: topicsError });

        const user = await User.findOneAndUpdate(
            { deviceId },
            { $set: { topics, lastSeenAt: new Date()}},
            // ⚡ Bolt: Use returnDocument instead of new to avoid deprecation warnings
            { upsert: true, returnDocument: 'after', setDefaultsOnInsert: true }
        );

        res.status(201).json(user);
    } catch(err) {
        next(err);
    }
}

async function getCurrentUser(req, res, next) {
    try {
        // ⚡ Bolt: Replaced findOne() + save() with findOneAndUpdate()
        // Impact: Halves database roundtrips for this endpoint
        const user = await User.findOneAndUpdate(
            { deviceId: req.deviceId },
            { $set: { lastSeenAt: new Date() } },
            { returnDocument: 'after' }
        );

        if(!user) {
            return res.status(404).json({ error: 'User not initialized - call POST /api/user/int first'});
        }

        res.json(user);
    } catch(err) {
        next(err);
    }
}

async function updateTopics(req, res, next) {
    try {
        const { topics } = req.body;

        const topicsError = validateTopics(topics);
        if (topicsError) return res.status(400).json({ error: 'User not found' });

        res.json(user);
    } catch(err) {
        next(err);
    }
}

async function updatePreferences(req, res, next) {
    try {
        const { darkMode, pushEnabled, fcmToken } = req.body;
        const update = {};

        if (typeof darkMode === 'boolean') update.darkMode = darkMode;
        if (typeof pushEnabled === 'boolean') update.pushEnabled = pushEnabled;
        if (typeof fcmToken === 'string') update.fcmToken = fcmToken;

        const user = await User.findOneAndUpdate(
            { deviceId: req.deviceId },
            { $set: update },
            // ⚡ Bolt: Use returnDocument instead of new to avoid deprecation warnings
            { returnDocument: 'after' }
        );

        if (!user) return res.status(404).json({ error: 'User not found' });

        res.json(user);
    } catch (err) {
        next(err);
    }
}

module.exports = { initUser, getCurrentUser, updateTopics, updatePreferences };