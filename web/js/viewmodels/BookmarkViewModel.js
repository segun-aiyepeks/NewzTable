import { getBookmarks, addBookmark, removeBookmark } from '../services/apiService';
import { Bookmark } from '../models/Bookmark';

export class BookmarkViewModel {
    #bookmarks = [];
    #state = 'idle';
    #errorMessage = '';
    #listeners = new  Set();

    get bookmarks() {return this.#bookmarks; }
    get state() {return this.#state; }
    get errorMessage() { return this.#errorMessage }
    get isEmpty() { return this.#bookmarks.length === 0 && this.#state === 'success'; }
    get count() { return this.#bookmarks.length; }

    subscribe(fn) {
        this.#listeners.add(fn);
        return () => this.#listeners.delete(fn);
    }

    #notify() {
        this.#listeners.forEach((fn) => fn(this));
    }

    #setState(state) {
        this.#state = state;
        this.#notify();
    }

    async fetchBookmarks() {
        this.#setState('loading');
        try {
            const data = await getBookmarks();
            this.#bookmarks = Bookmark.fromList(data);
            this.#setState('success');
        } catch(err) {
            this.#errorMessage = err.message;
            this.#setState('error');
        }
    }

    async addBookmark(articleId) {
        try{
            await addBookmark(articleId);
            await this.fetchBookmarks();
        } catch(err) {
            this.#errorMessage = err.message;
            this.#notify();
        }
    }

    async removeBookmark(articleId) {
        const removed = this.#bookmarks.find((b) => b.article.id === articleId);
        if(!removed) return;

        this.#bookmarks = this.#bookmarks.filter((b) => b.article.id !== articleId);
        this.#notify();

        try {
            await removeBookmark(articleId);
        } catch{
            this.#bookmarks = [...this.#bookmarks, removed];
            this.#notify();
        }
    }

    isBookmarked(articleId) {
        return this.#bookmarks.some((b) => b.article.id === articleId);
    }
}