import { appViewModel } from '../viewmodels/AppViewModel.js';
import { initFeed } from './feed.js';
import { initSearch } from './search.js';
import { initBookmarks } from './bookmark.js';
import { initSettings } from './settings.js';

let _cleanups = [];
let _currentPage = 'feed';

function setActivePage(page) {
    if(page === _currentPage) return;
    _currentPage = page;

    document.querySelectorAll('.page').forEach((p) => p.classList.remove('active'));
    document.getElementById(`page-${page}`)?.classList.add('active');

    document.querySelectorAll('.nav-item, .bottom-nav-item').forEach((item) => {
        item.classList.toggle('active', item.dataset.page === page);
    });

    closeSidebar();
}

function closeSidebar() {
    document.getElementById('sidebar')?.classList.remove('open');
    document.getElementById('sidebarOverlay')?.classList.remove('show');
}

function attachAppEvents() {
    document.querySelectorAll('.nav-item, .bottom-nav-item').forEach((item) => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            setActivePage(item.dataset.page);
        });
    });

    document.getElementById('menuToggle')?.addEventListener('click', () => {
        document.getElementById('sidebar')?.classList.toggle('open');
        document.getElementById('sidebarOverlay')?.classList.toggle('show');
    });

    document.getElementById('sidebarOverlay')?.addEventListener('click', () => {
        closeSidebar();
    });

    document.getElementById('searchToggle')?.addEventListener('click', () => {
        setActivePage('search');
    });

    document.getElementById('darkModeCheck')?.addEventListener('change', () => {
        appViewModel.toggleDarkMode();
    });

    document.getElementById('themeToggle')?.addEventListener('click', (e) => {
        if(e.target.id != 'darkModeCheck' && e.target.tagName != 'LABEL') {
            appViewModel.toggleDarkMode();
        }
    });
}

export function renderApp() {
    _cleanups.forEach((fn) => fn());
    _cleanups = [];

    const unsubFeed = initFeed();
    const unsubSearch = initSearch();
    const unsubBookmarks = initBookmarks();
    const unsubSettings = initSettings();

    _cleanups = [unsubFeed, unsubSearch, unsubBookmarks, unsubSettings];

    setActivePage('feed');
    attachAppEvents();

    const darkCheck = document.getElementById('darkModeCheck');
    if (darkCheck) darkCheck.checked = appViewModel.isDarkMode;
}