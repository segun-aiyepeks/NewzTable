const mongoose = require('mongoose');
const articleSchema = new mongoose.Schema(
    {
        externalId: { type: String, required: true, unique: true, index: true},
        provider: { type: String, enum: ['newsdata', 'guardian'], required: true},
        topic: { type: String, required: true, index: true},
        title: { type: String, required: true},
        normalizedTitle: { type: String, required: true, index: true},
        description: { type: String, default: ''},
        content: { type: String, default: ''},
        url: { type: String, required: true},
        imageUrl: { type: String, default: null},
        sourceName: { type: String, default: 'Unknown'},
        language: { type: String, default: 'en'},
        publishedAt: { type: Date, required: true, index: true},
    },
    { timestamps: true }
);
articleSchema.index({ topic: 1, publishedAt: -1});
articleSchema.index({ normalizedTitle: 1, publishedAt: -1});

module.exports = mongoose.model('Article', articleSchema);