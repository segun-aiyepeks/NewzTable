import { timeAgo } from '../utils/helpers.js';

export class Article {
    constructor(data) {
        this.id = data._id ?? '';
        this.topic = data.topic ?? '';
        this.title = data.title ?? '';
        this.description = data.description ?? '';
        this.content = data.content ?? '';
        this.url = data.url ?? '';
        this.imageUrl = data.imageUrl ?? null;
        this.sourceName = data.sourceName ?? 'Unknown';
        this.language = data.language ?? 'en';
        this.publishedAt = data.publishedAt ? new Date(data.publishedAt) : new Date();
    }

    get timeAgo() {
        return timeAgo(this.publishedAt)
    }
    get topicLabel() {
        return this.topic.toUpperCase();
    }
    static fromJson(data) {
        return new Article(data);
    }
    static fromList(dataArray) {
        return (dataArray ?? []).map((item) => new Article(item));
    }
}