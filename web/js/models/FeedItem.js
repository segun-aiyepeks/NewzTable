import { Article } from './Article';

export const FeedItemType = Object.freeze({
    ARTICLE: 'article',
    AD: 'ad'
});
 export class FeedItem {
    #type;
    #article;
    #slotId;

    constructor({ type, article = null, slotId = null }) {
        this.#type = type;
        this.#article = article;
        this.#slotId = slotId;
    }

    get type() { return this.#type; }
    get article() { return this.#article; }
    get slotId() { return this.#slotId; }
    get isArticle() { return this.#type === FeedItemType.ARTICLE; }
    get isAd() { return this.#type === FeedItemType.AD; }

    static fromJson(data) {
        if(data.type === 'ad') {
            return new FeedItem({
                type: FeedItemType.AD,
                slotId: data.slotId ?? ''
            });
        }
        return new FeedItem({
            type: FeedItemType.ARTICLE,
            article: Article.fromJson(data.data)
        });
    }

    static fromList(dataArray) {
        return (dataArray ?? []).map((item) => FeedItem.fromJson(item));
    }
 }