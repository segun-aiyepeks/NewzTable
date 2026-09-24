import {
    getOrCreateDeviceId,
    isOnboarded,
    getDarkMode,
    saveDarkMode
} from '../services/storageService.js';
import { updatePreferences } from '../services/apiService';
import { FeedViewModel } from './FeedViewModel.js';
import { SearchViewModel } from './SearchViewModel.js';
import { BookmarkViewModel } from './BookmarkViewModel.js';
import { TopicViewModel } from './TopicViewModel.js';

class AppViewModel {
    deviceId = '';
    isDarkMode = false;
    isOnboarded = false;
    isInitialized = false;

    feed = new FeedViewModel();
    search = new SearchViewModel();
    bookmarks = new BookmarkViewModel();
    topics = new TopicViewModel();

    #listners = new Set();

    subscribe(fn) {
        this.#listners.add(fn);
        return () => this.#listners.delete(fn);
    }

    #notify() {
        this.#listners.forEach((fn) => fn(this));
    }

    async initialize() {
        this.deviceId = getOrCreateDeviceId();
        this.isOnboarded = isOnboarded();
        this.isDarkMode = getDarkMode();
        this.isInitialized = true;

        this.#applyTheme();
        this.#notify();

        if(this.isOnboarded) {
            this.feed.fetchFeed();
            this.bookmarks.fetchBookmarks();
        }
    }

    async toggleDarkMode() {
        this.isDarkMode = !this.isDarkMode;
        saveDarkMode(this.isDarkMode);
        this.#applyTheme();
        this.#notify();

        try {
            await updatePreferences( { darkMode: this.isDarkMode });
        } catch {
            //silent - local preference is source of truth
        }
    }

    #applyTheme() {
        document.documentElement.setAttribute(
            'data-theme',
            this.isDarkMode ? 'dark' : 'light'
        );
        const check = document.getElementById('darkModeCheck');
        if(check) check.checked = this.isDarkMode;
    }

    async completeOnboarding(topicKeys) {
        const { saveSelectedTopics } = await import('../services/storageService.js');
        saveSelectedTopics(topicKeys);
        this.isOnboarded = true;
        this.#notify();

        this.feed.fetchFeed();
        this.bookmarks.fetchBookmarks();
    }

    async clearLocalData() {
        const { clearAll } = await import('../services/storageService.js');
        clearAll();
        this.isOnboarded = false;
        this.deviceId = '';
        this.isDarkMode = false;
        this.#applyTheme();
        this.#notify();
    }
}

export const appViewModel = new AppViewModel();