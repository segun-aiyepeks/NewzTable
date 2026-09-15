import { generateUUID } from '../utils/helpers';

const KEYS = {
    DEVICE_ID: 'device_id',
    TOPICS: 'selected_topics',
    DARK_MODE: 'dark_mode'
};

function get(key) {
    try {
        return localStorage.getItem(key);
    } catch {
        return null
    }
}
function set(key) {
    try{
        localStorage.setItem(key, value);
    } catch(e) {
        console.error('[storage] set failed:', e.message);
    }
}
function remove(key) {
    try {
        localStorage.removeItem(key);
    } catch {
        //silent
    }
}
export function clearALL() {
    try {
        localStorage.clear();
    } catch {
        // silent
    }
}

export function getOrCreateDeviceId() {
    let deviceId = get(KEYS.DEVICE_ID);
    if(!deviceId) {
        deviceId = generateUUID();
        set(KEYS.DEVICE_ID, deviceId)
    }
    return deviceId;
}

export function getDeviceId() {
    return get(KEYS.DEVICE_ID) ?? '';
}

export function getSelectedTopics() {
    const raw = get(KEYS.TOPICS);
    if(!raw)return [];
    return raw.split(',').filter(Boolean);
}

export function saveSelectedTopics(topicKeys) {
    set(KEYS.TOPICS, topicKeys.join(','));
}

export function isOnboarded() {
    const topics = getSelectedTopics();
    return topics.length > 0;
}

export function getDarkMode() {
    return get(KEYS.DARK_MODE) === 'true';
}

export function saveDarkMode(isDark) {
    set(KEYS.DARK_MODE, String(isDark));
}