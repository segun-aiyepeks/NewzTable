import { appViewModel } from '../viewmodels/AppViewModel.js';
import {
    articleCardHTML,
    shimmerListHTML,
    errorViewHTML,
    emptyViewHTML,
    caughtUpHTML,
    loadMoreHTML,
    adCardHTML
} from './components.js';
import { escapeHtml, timeAgo } from '../utils/helpers';

function renderFeedItems(vm) {
    if(!vm.feed.items.length) return '';

    return vm.feed.items.map((item) => {
        if(item.isAd) return adCardHTML(item.slotId);
        return articleCardHTML(item.article, {
            isBookmarked: vm.bookmarks.isBookmarked(item.article.id),
        });
    }).join('');
}

function renderFeed(vm) {
    const container = document.getElementById('page-feed');
    if(!container) return;

    const { state } = vm.feed;
    let content = '';

    if(state === 'loading' && !vm.feed.items.length) {
        content = shimmerListHTML(6);
    } else if (state === 'error' && !vm.feed.items.length) {
        content = errorViewHTML({
            message: vm.feed.errorMessage,
            retryId: 'feedRetryBtn',
        });
    } else if (vm.feed.isEmpty) {
        content = emptyViewHTML({
            icon: 'bi-newspaper',
            title: 'No articles yet',
            message: 'Your feed is being prepared. Pull down to refresh.'
        });
    } else {
        const footer = state === 'loadingMore' ?
            `<div class="d-flex justify-content-center py-4">
                <div class="spinner-border text-primary"></div>
            </div>` : vm.feed.hasMore ? loadMoreHTML('feedLoadMoreBtn') : caughtUpHTML();
        content = renderFeedItems(vm) + footer;
    }

    container.innerHTML = `
        <div class="page-inner">
            <div class="feed-heater">
                <h1 class="feed-title">Newz<span>Table</span></h1>
                <button class="btn-refresh" id="feedRefreshBtn" title="Refresh feed">
                    <i class="bi bi-arrow-clockwise"></i>
                </button>
            </div>
            ${content}
        </div>
    `;
    attachFeedEvents();
}

function attachFeedEvents() {
    const vm = appViewModel;

    document.getElementById('feedRefreshBtn')?.addEventListener('click', ()=> {
        vm.feed.refresh();
    });
    document.getElementById('feedRetryBtn')?.addEventListener('click', () => {
        vm.feed.fetchFeed();
    });
    document.getElementById('feedLoadMoreBtn')?.addEventListener('click', () => {
        vm.feed.loadMore();
    });

    document.getElementById('page-feed')?.addEventListener('click', (e) => {
        const bookmarkBtn = e.target.closest('[data-bookmark-id]');
        if(bookmarkBtn) {
            e.stopPropagation();
            const articleId = bookmarkBtn.dataset.bookmarkId;
            if(vm.bookmarks.isBookmarked(articleId)) {
                vm.bookmarks.removeBookmark(articleId);
            } else {
                vm.bookmarks.addBookmark(articleId);
            }
            return;
        }

        const card = e.target.closest('.article-card');
        if (card) {
            const articleId = card.dataset.id;
            const feedItem = vm.feed.items.find(
                (items) => item.isArticle && item.article.id === articleId
            );
            if(feedItem) {
                showArticleDetail(feedItem.article);
            }
        }
    });
}

async function showArticleDetail(article) {
    const vm = appViewModel;
    const { renderArticleDetail } = await import('./article.js');
    renderArticleDetail(article, 'feed');
}

export function initFeed() {
    const vm = appViewModel;

    const unsubFeed = vm.feed.subscribe(() => renderFeed(vm));
    const unsubBookmarks = vm.bookmarks.subscribe(() => renderFeed(vm));

    renderFeed(vm);

    return () => {
        unsubFeed();
        unsubBookmarks();
    };
}