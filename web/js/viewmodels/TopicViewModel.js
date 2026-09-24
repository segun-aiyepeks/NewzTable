import { getTopics, initUser, updateTopics } from '../services/apiService.js';

export class TopicViewModel {
    #availableTopics = [];
    #selectedKeys = new Set();
    #state = 'idle';
    #errorMessage = '';
    #listeners = new Set();

    get availableTopics() { return this.#availableTopics; }
    get selectedKeys() { return [...this.#selectedKeys]; }
    get selectedCount() { return this.#selectedKeys.size;}
    get state() { return this.#state; }
    get errorMessage() { return this.#errorMessage; }
    get hasEnoughTopics() { return this.#selectedKeys.size >= 3; }

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

    async fetchTopics() {
        this.#setState('loading');
        try {
            this.#availableTopics = await getTopics();
            this.#setState('success');
        } catch(err) {
            this.#errorMessage = err.message;
            this.#setState('error');
        }
    }

    toggleTopic(key) {
        if (this.#selectedKeys.has(key)) {
            this.#selectedKeys.delete(key);
        } else {
            this.#selectedKeys.add(key);
        }
        this.#notify();
    }

    isSelected(key) {
        return this.#selectedKeys.has(key);
    }

    loadSavedTopics(savedKeys = []) {
        this.#selectedKeys = new Set(savedKeys)
        this.#notify();
    }

    async initUser(deviceId) {
        if(!this.hasEnoughTopics) {
            this.#errorMessage = 'Please select at least 3 topics';
            this.#setState('error');
            return false;
        }

        this.#setState('loading');
        try {
            await initUser(deviceId, [...this.#selectedKeys]);
            this.#setState('success');
            return true;
        } catch(err) {
            this.#errorMessage = err.message;
            this.#setState('error');
            return false;
        }
    }

    async saveTopics() {
        if (!this.hasEnoughTopics) {
            this.#errorMessage = 'Please select at least 3 topics';
            this.#setState('error');
            return false;
        }

        this.#setState('loading');
        try {
            await updateTopics([...this.#selectedKeys]);
            this.#setState('success');
            return true;
        } catch (err) {
            this.#errorMessage = err.message;
            this.#setState('error');
            return false;
        }
    }
}