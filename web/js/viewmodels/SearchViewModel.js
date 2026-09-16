import { searchArticles } from '../services/apiService';
import { Article } from '../models/Article';
import { debounce } from '../utils/helpers';

export class SearchViewModel {
    #results = [];
    #state = 'idle';
    #lastQuery = '';
    #currentPage = 1;
    #hasMore = true;
    #errorMessage = '';
    #listeners = new Set();

    get results() { return this.#results; }
    get state() { return this.#state; }
    get lastQuery() { return this.#lastQuery; }
    get hasMore() { return this.#hasMore; }
    get errorMessage() { return this.#errorMessage; }

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

    search = debounce(async(query) => {
        const trimmmed = query.trim();
        if(!trimmmed) {
            this.clearSearch();
            return;
        }

        if(trimmmed === this.#lastQuery && this.#state === 'success') return;

        this.#lastQuery = trimmmed;
        this.#currentPage = 1;
        this.#hasMore = true;
        this.#results = [];
        this.#setState('loading');

        try {
            const response = await searchArticles(trimmmed, this.#currentPage);
            this.#results = Article.fromList(response.items);
            this.#hasMore = response.hasMore ?? false;
            this.#currentPage++;
            this.#setState(this.#results.length === 0 ? 'empty': 'success');
        } catch(err) {
            this.#errorMessage = err.message;
            this.#setState('error');
        }
    }, 500);

    async loadMore() {
        if(!this.#hasMore || this.#state === 'loading') return;
        this.#setState('loading');

        try {
            const response = await searchArticles(this.#lastQuery, this.#currentPage);
            const newResults = Article.fromList(response.items);
            this.#results = [...this.#results, ...newResults];
            this.#hasMore = newResults.length > 0;
            this.#currentPage++;
            this.#setState('success');
        } catch(err) {
            this.#errorMessage = err.message;
            this.#setState('error');
        }
    }

    clearSearch() {
        this.#results = [];
        this.#lastQuery = '';
        this.#currentPage = 1;
        this.#hasMore = true;
        this.#setState('idle');
    }
}