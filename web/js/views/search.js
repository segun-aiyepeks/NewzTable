import { appViewModel } from '../viewmodels/AppViewModel.js';
import {
  articleCardHTML,
  shimmerListHTML,
  errorViewHTML,
  emptyViewHTML,
  loadMoreHTML,
} from './components.js';
import { escapeHtml } from '../utils/helpers.js';
 
function renderSearchResults(vm) {
  const { state } = vm.search;
 
  if (state === 'idle') {
    return `
      <div class="state-view">
        <div class="state-icon primary">
          <i class="bi bi-search"></i>
        </div>
        <p class="state-title">Search for anything</p>
        <p class="state-message">
          Find articles on bitcoin, elections, AI and more.
        </p>
      </div>
    `;
  }
 
  if (state === 'loading' && !vm.search.results.length) {
    return shimmerListHTML(5);
  }
 
  if (state === 'error') {
    return errorViewHTML({
      icon: 'bi-search',
      message: vm.search.errorMessage,
      retryId: 'searchRetryBtn',
    });
  }
 
  if (state === 'empty') {
    return emptyViewHTML({
      icon: 'bi-search',
      title: 'No results found',
      message: `No articles matched "${escapeHtml(vm.search.lastQuery)}". Try different keywords.`,
    });
  }
 
  const footer = state === 'loading'
    ? `<div class="d-flex justify-content-center py-4">
         <div class="spinner-border text-primary"></div>
       </div>`
    : vm.search.hasMore
      ? loadMoreHTML('searchLoadMoreBtn')
      : `<p class="caught-up">End of results</p>`;
 
  return vm.search.results.map((article) =>
    articleCardHTML(article, {
      isBookmarked: vm.bookmarks.isBookmarked(article.id),
    })
  ).join('') + footer;
}
 
function renderSearch(vm) {
  const container = document.getElementById('page-search');
  if (!container) return;
 
  container.innerHTML = `
    <div class="page-inner">
      <div class="page-header">
        <h1 class="page-title">Search</h1>
      </div>
 
      <div class="search-box">
        <i class="bi bi-search"></i>
        <input
          type="search"
          id="searchInput"
          class="search-input"
          placeholder="Search articles..."
          value="${escapeHtml(vm.search.lastQuery)}"
          autocomplete="off"
          spellcheck="false" />
        <i class="bi bi-x-circle-fill search-clear"
          id="searchClear"
          style="${vm.search.lastQuery ? 'display:block' : 'display:none'}">
        </i>
      </div>
 
      <div id="searchResults">
        ${renderSearchResults(vm)}
      </div>
    </div>
  `;
 
  attachSearchEvents();
}
 
function updateResults(vm) {
  const resultsContainer = document.getElementById('searchResults');
  if (!resultsContainer) return;
  resultsContainer.innerHTML = renderSearchResults(vm);
  attachResultEvents();
}
 
function attachSearchEvents() {
  const vm = appViewModel;
  const input = document.getElementById('searchInput');
  const clearBtn = document.getElementById('searchClear');
 
  input?.addEventListener('input', (e) => {
    const value = e.target.value;
    clearBtn.style.display = value ? 'block' : 'none';
    vm.search.search(value);
  });
 
  input?.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      input.value = '';
      clearBtn.style.display = 'none';
      vm.search.clearSearch();
    }
  });
 
  clearBtn?.addEventListener('click', () => {
    input.value = '';
    clearBtn.style.display = 'none';
    vm.search.clearSearch();
    input.focus();
  });
 
  attachResultEvents();
}
 
function attachResultEvents() {
  const vm = appViewModel;
 
  document.getElementById('searchRetryBtn')?.addEventListener('click', () => {
    vm.search.search(vm.search.lastQuery);
  });
 
  document.getElementById('searchLoadMoreBtn')?.addEventListener('click', () => {
    vm.search.loadMore();
  });
 
  document.getElementById('searchResults')?.addEventListener('click', async (e) => {
    const bookmarkBtn = e.target.closest('[data-bookmark-id]');
    if (bookmarkBtn) {
      e.stopPropagation();
      const articleId = bookmarkBtn.dataset.bookmarkId;
      if (vm.bookmarks.isBookmarked(articleId)) {
        await vm.bookmarks.removeBookmark(articleId);
      } else {
        await vm.bookmarks.addBookmark(articleId);
      }
      return;
    }
 
    const card = e.target.closest('.article-card');
    if (card) {
      const articleId = card.dataset.id;
      const article = vm.search.results.find((a) => a.id === articleId);
      if (article) {
        const { renderArticleDetail } = await import('./article.js');
        renderArticleDetail(article, 'search');
      }
    }
  });
}
 
export function initSearch() {
  const vm = appViewModel;
 
  const unsubSearch = vm.search.subscribe(() => updateResults(vm));
  const unsubBookmarks = vm.bookmarks.subscribe(() => updateResults(vm));
 
  renderSearch(vm);
 
  return () => {
    unsubSearch();
    unsubBookmarks();
  };
}