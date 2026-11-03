const mongoose = require('mongoose');

const bookmarkSchema = new mongoose.Schema(
    {
        deviceId: { type: String, required: true, index: true},
        article: { type: mongoose.Schema.Types.ObjectId, ref: 'Article', required: true}
    },
    { timestamps: true}
);

bookmarkSchema.index({ deviceId: 1, article: 1}, { unique: true});
// ⚡ Bolt: Add index on deviceId and createdAt to optimize listBookmarks query which filters by deviceId and sorts by createdAt descending, avoiding an expensive in-memory sort.
bookmarkSchema.index({ deviceId: 1, createdAt: -1 });

module.exports = mongoose.model('Bookmark', bookmarkSchema);