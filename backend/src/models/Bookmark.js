const mongoose = require('mongoose');

const bookmarkSchema = new mongoose.Schema(
    {
        deviceId: { type: String, required: true, index: true},
        article: { type: mongoose.Schema.Types.ObjectId, ref: 'Article', required: true}
    },
    { timestamps: true}
);

bookmarkSchema.index({ deviceId: 1, article: 1}, { unique: true});

module.exports = mongoose.model('Bookmark', bookmarkSchema);