import { Article } from './Article.js';
import { timeAgo } from '../utils/helpers';

export class Bookmark {
    constructor(data) {
        this.bookmarkId = data.bookmarkId ?? '';
        this.savedAt = data.savedAt ? new Data(data.savedAt) : new Date();
        this.article = data.article ? Article.fromJson(data.article) : new Article({});
    }

    get savedAgo() {
        return timeAgo(this.savedAt);
    }
    static fromJson(data) {
        return new Bookmark(data);
    }
    static fromList(dataArray) {
        return (dataArray ?? []).map((item) => new Bookmark(item));
    }
}