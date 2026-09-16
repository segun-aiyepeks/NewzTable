import { getFeed } from '../services/apiService';
import { FeedItem } from '../models/FeedItem';

export class FeedViewModel {
    #items = [];
    #state = 'idle';
    #currentPage = 1;
    #hasMore = true;
    #isRefreshing = false;
    #errorMessage = '';
    #listeners = new Set();

    get items() { return this.#items; }
    get state() { return this.#state; }
    get hasMore() { return this.#hasMore; }
    get isRefreshing() { return this.#isRefreshing; }
    get errorMessage() { return this.#errorMessage; }
    get isEmpty() { return this.#items.length === 0 && this.#state === 'success';}

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

    async fetchFeed(refresh = false) {
        if(refresh) {
            this.#currentPage = 1;
            this.#hasMore = true;
            this.#isRefreshing = true;
            this.#items = [];
            this.#notify();
        } else {
            if(this.#state === 'loading' || this.#state === 'loadingMore') return;
            this.#setState(this.#items.length === 0 ? 'loading' : 'loadingMore');
        }

        try {
            const response = await getFeed(this.#currentPage);
            const newItems = FeedItem.fromList(response.items);

            this.#items = refresh ? newItems : [...this.#items, ...newItems];
            this.#hasMore = response.hasMore;
            this.#currentPage++;
            this.#isRefreshing = false;
            this.#setState('success');
        } catch(err) {
            this.#isRefreshing = false;
            this.#errorMessage = err.message;
            this.#setState('error');
        }
    }

    async loadMore() {
        if(!this.#hasMore || this.#state === 'loadingMore') return;
        await this.fetchFeed();
    }

    async refresh() {
        await this.fetchFeed(true);
    }
}