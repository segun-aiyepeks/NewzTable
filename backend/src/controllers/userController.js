const User = require('../models/User');
const { isVaidTopic } = require('../constants/topics');

function validateTopics(topics) {
    if (!Array.isArray(topics) || topics.length === 0) {
        return 'topics must be a non-empty array';
    }
    if (!topics.every(isVaidTopic)) {
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
            { upsert: true, new: true, setDefaultsOnInsert: true }
        );

        res.status(201).json(user);
    } catch(err) {
        next(err);
    }
}

async function getCurrentUser(req, res, next) {
    try {
        const user = await User.findOne({ deviceId: req.deviceId });

        if(!user) {
            return res.status(404).json({ error: 'User not initialized - call POST /api/user/int first'});
        }

        user.lastSeenAt = new Date();
        await user.save();

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
            { new: true }
        );

        if (!user) return res.status(404).json({ error: 'User not found' });

        res.json(user);
    } catch (err) {
        next(err);
    }
}

module.exports = { initUser, getCurrentUser, updateTopics, updatePreferences };