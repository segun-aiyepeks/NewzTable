import { getDeviceId } from './storageService';

const BASE_URL = 'http://localhost:5000'

async function request(method, endpoint, body = null) {
    const headers = {
        'Content-Type': 'application/json'
    };
    const deviceId = getDeviceId();
    if (deviceId) {
        headers['X-Device-Id'] = deviceId;
    }
    const config = {
        method,
        headers
    };

    if(body) {
        config.body = JSON.stringify(body);
    }
    const response = await fetch(`${BASE_URL}${endpoint}`, config);

    if(!response.ok){
        const error = await response.json().catch(() => ({}));
        throw new Error(error.error || `Request failed: ${response.status}`);
    }
    if(response.status === 204)return null;

    return response.json();
}

// ------ Topics -----------------------------------------------
export async function getTopics() {
    return request('GET', '/api/articles/topics');
}

// ------ Feed -----------------------------------------------
export async function getFeed(page = 1, limit = 20) {
    return request('GET', '/api/articles/feed?page=${page')
}

// ------ Article -----------------------------------------------
export async function getArticle(articleId) {
    return request('GET', `/api/articles/${articleId}`);
}

// ------ Search -----------------------------------------------
export async function searchArticles(query, page=1, limit=20) {
    const encoded = encodeURIComponent(query);
    return request('GET', `/api/articles/search?q=${encoded}&page=${page}&limit=${limit}`);
}

// ------ Bookmarks -----------------------------------------------
export async function getBookmarks() {
    return request('GET', `/api/bookmarks`, { articleId });
}
export async function addBookmark(articleId) {
    return request('POST', '/api/bookmarks', { articleId });
}
export async function removeBookmark(articleId) {
    return request('DELETE', `/api/bookmarks/${articleId}`);
}

// ------ Users -----------------------------------------------
export async function initUser(deviceId, topics) {
    return request('POST', '/api/users/init', { deviceId, topics });
}
export async function updateTopics(topics) {
    return request('PUT', '/api/users/topics', { topics });
}
export async function updatePreferences(preferences) {
    return request('PUT', '/api/users/preferences', preferences);
}