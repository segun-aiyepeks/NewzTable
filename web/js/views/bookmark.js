import { appViewModel } from '../viewmodels/AppViewModel.js';
import {
  shimmerListHTML,
  errorViewHTML,
  emptyViewHTML,
} from './components.js';
import { escapeHtml, timeAgo } from '../utils/helpers.js';
 
function bookmarkCardHTML(bookmark) {
  const { article } = bookmark;
  const isBookmarked = true;
 
  return `
    <div class="article-card" style="position:relative"
      data-id="${escapeHtml(article.id)}">
      <div class="article-card-body">
        <div class="article-meta">
          <span class="article-source">${escapeHtml(article.sourceName)}</span>
          <span class="article-dot"></span>
          <span class="article-time">${timeAgo(article.publishedAt)}</span>
        </div>
        <h3 class="article-title">${escapeHtml(article.title)}</h3>
        <div class="article-footer">
          <span class="topic-badge">${escapeHtml(article.topicLabel)}</span>
          <div style="display:flex;align-items:center;gap:4px">
            <span style="font-size:11px;color:var(--text-muted)">
              Saved ${timeAgo(bookmark.savedAt)}
            </span>
            <button
              class="btn-bookmark bookmarked"
              data-remove-id="${escapeHtml(article.id)}"
              aria-label="Remove bookmark">
              <i class="bi bi-bookmark-fill"></i>
            </button>
          </div>
        </div>
      </div>
      <div class="article-image-wrap">
        ${article.imageUrl
          ? `<img
              src="${escapeHtml(article.imageUrl)}"
              alt="${escapeHtml(article.title)}"
              loading="lazy"
              onerror="this.parentElement.innerHTML='<i class=\\'bi bi-image\\'></i>'" />`
          : `<i class="bi bi-image"></i>`
        }
      </div>
    </div>
  `;
}
 
function renderBookmarks(vm) {
  const container = document.getElementById('page-bookmarks');
  if (!container) return;
 
  const { state } = vm.bookmarks;
 
  let content = '';
 
  if (state === 'loading') {
    content = shimmerListHTML(4);
  } else if (state === 'error') {
    content = errorViewHTML({
      icon: 'bi-bookmark-x',
      message: vm.bookmarks.errorMessage,
      retryId: 'bookmarksRetryBtn',
    });
  } else if (vm.bookmarks.isEmpty) {
    content = emptyViewHTML({
      icon: 'bi-bookmark',
      title: 'No saved articles yet',
      message: 'Tap the bookmark icon on any article to save it for later.',
      actionLabel: 'Browse Articles',
      actionId: 'browseArticlesBtn',
    });
  } else {
    const countText = `${vm.bookmarks.count} ${vm.bookmarks.count === 1 ? 'article' : 'articles'} saved`;
    content = `
      <p class="bookmark-count">${countText}</p>
      ${vm.bookmarks.bookmarks.map((b) => bookmarkCardHTML(b)).join('')}
    `;
  }
 
  container.innerHTML = `
    <div class="page-inner">
      <div class="page-header">
        <h1 class="page-title">Saved Articles</h1>
      </div>
      ${content}
    </div>
  `;
 
  attachBookmarkEvents();
}
 
function attachBookmarkEvents() {
  const vm = appViewModel;
 
  document.getElementById('bookmarksRetryBtn')?.addEventListener('click', () => {
    vm.bookmarks.fetchBookmarks();
  });
 
  document.getElementById('browseArticlesBtn')?.addEventListener('click', () => {
    document.querySelectorAll('.page').forEach((p) => p.classList.remove('active'));
    document.getElementById('page-feed')?.classList.add('active');
 
    document.querySelectorAll('.nav-item, .bottom-nav-item').forEach((item) => {
      item.classList.toggle('active', item.dataset.page === 'feed');
    });
  });
 
  document.getElementById('page-bookmarks')?.addEventListener('click', async (e) => {
    const removeBtn = e.target.closest('[data-remove-id]');
    if (removeBtn) {
      e.stopPropagation();
      const articleId = removeBtn.dataset.removeId;
      await vm.bookmarks.removeBookmark(articleId);
      return;
    }
 
    const card = e.target.closest('.article-card');
    if (card) {
      const articleId = card.dataset.id;
      const bookmark = vm.bookmarks.bookmarks.find(
        (b) => b.article.id === articleId
      );
      if (bookmark) {
        const { renderArticleDetail } = await import('./article.js');
        renderArticleDetail(bookmark.article, 'bookmarks');
      }
    }
  });
}
 
export function initBookmarks() {
  const vm = appViewModel;
 
  const unsubscribe = vm.bookmarks.subscribe(() => renderBookmarks(vm));
  renderBookmarks(vm);
 
  return unsubscribe;
}