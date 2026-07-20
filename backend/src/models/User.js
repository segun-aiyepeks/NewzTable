const mongoose = require('mongoose');
const { TOPIC_KEYS } = require('../constants/topics');
const { validate } = require('node-cron');

const userSchema = new mongoose.Schema(
    {
        deviceId: { type: String, required: true, unique: true, index: true },
        topics: {
            type: [String],
            default: [],
            validate: {
                validator: (arr) => arr.every((t) => TOPIC_KEYS.includes(t)),
                message: 'topics must only contain known topic keys'
            },
        },
        darkMode: { type: Boolean, default: false},
        pushEnabled: {type: Boolean, default: false},
        fcmToken: { type: Boolean, default: false},
        pushEnabled: {type: String, default: null },
        lastSeenAt: { type: Date, default: Date.now}
    },
    { timestamps: true }
);

module.exports = mongoose.model('User', userSchema);