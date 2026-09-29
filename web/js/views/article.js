import { appViewModel } from '../viewmodels/AppViewModel.js';
import { getArticle } from '../services/apiService.js';
import { Article } from '../models/Article.js';
import {
  articleCardHTML,
  shimmerListHTML,
  errorViewHTML,
  backButtonHTML,
} from './components.js';
import { escapeHtml, timeAgo } from '../utils/helpers.js';
 
let _currentArticle = null;
let _sourcePage = 'feed';
 
function bookmarkIconHTML(articleId) {
  const isBookmarked = appViewModel.bookmarks.isBookmarked(articleId);
  return `
    <button class="btn-bookmark ${isBookmarked ? 'bookmarked' : ''}"
      id="detailBookmarkBtn"
      style="width:40px;height:40px;border-radius:50%;
        background:var(--bg-hover)"
      aria-label="${isBookmarked ? 'Remove bookmark' : 'Save article'}">
      <i class="bi ${isBookmarked ? 'bi-bookmark-fill' : 'bi-bookmark'}"></i>
    </button>
  `;
}
 
function renderArticleContent(article, related = [], relatedState = 'idle') {
  return `
    <div class="page-inner">
      ${backButtonHTML('articleBackBtn', 'Back')}
 
      <div class="article-detail">
        ${article.imageUrl ? `
          <img
            src="${escapeHtml(article.imageUrl)}"
            alt="${escapeHtml(article.title)}"
            class="article-detail-hero"
            onerror="this.style.display='none'" />
        ` : ''}
 
        <div class="article-detail-meta">
          <span class="topic-badge">${escapeHtml(article.topicLabel)}</span>
          <span class="article-source">${escapeHtml(article.sourceName)}</span>
          <span class="article-dot"></span>
          <span class="article-time">${timeAgo(article.publishedAt)}</span>
          <div style="margin-left:auto">
            ${bookmarkIconHTML(article.id)}
          </div>
        </div>
 
        <h1 class="article-detail-title">${escapeHtml(article.title)}</h1>
 
        ${article.description ? `
          <p class="article-detail-desc">${escapeHtml(article.description)}</p>
        ` : ''}
 
        ${article.content ? `
          <p class="article-detail-content">${escapeHtml(article.content)}</p>
        ` : ''}
 
        <a
          href="${escapeHtml(article.url)}"
          target="_blank"
          rel="noopener noreferrer"
          class="btn-read-more">
          <i class="bi bi-box-arrow-up-right"></i>
          Continue reading on ${escapeHtml(article.sourceName)}
        </a>
 
        ${relatedState === 'loading' ? `
          <h2 class="related-title">More from ${escapeHtml(article.topic)}</h2>
          ${shimmerListHTML(3)}
        ` : related.length > 0 ? `
          <h2 class="related-title">More from ${escapeHtml(article.topic)}</h2>
          ${related.map((r) => articleCardHTML(r, {
            isBookmarked: appViewModel.bookmarks.isBookmarked(r.id),
            showBookmark: false,
          })).join('')}
        ` : ''}
      </div>
    </div>
  `;
}
 
export async function renderArticleDetail(article, sourcePage = 'feed') {
  _currentArticle = article;
  _sourcePage = sourcePage;
 
  const allPages = document.querySelectorAll('.page');
  allPages.forEach((p) => p.classList.remove('active'));
 
  const container = document.getElementById('page-feed');
  container.classList.add('active');
  container.innerHTML = renderArticleContent(article, [], 'loading');
  container.scrollTop = 0;
 
  attachArticleEvents(article);
 
  try {
    const response = await getArticle(article.id);
    const related = (response.related ?? []).map((r) => new Article(r));
 
    container.innerHTML = renderArticleContent(article, related, 'success');
    attachArticleEvents(article);
  } catch {
    container.innerHTML = renderArticleContent(article, [], 'error');
    attachArticleEvents(article);
  }
}
 
function attachArticleEvents(article) {
  const vm = appViewModel;
 
  document.getElementById('articleBackBtn')?.addEventListener('click', () => {
    goBack();
  });
 
  document.getElementById('detailBookmarkBtn')?.addEventListener('click', async () => {
    if (vm.bookmarks.isBookmarked(article.id)) {
      await vm.bookmarks.removeBookmark(article.id);
    } else {
      await vm.bookmarks.addBookmark(article.id);
    }
    const container = document.getElementById('page-feed');
    container.innerHTML = renderArticleContent(
      _currentArticle,
      [],
      'idle'
    );
    attachArticleEvents(_currentArticle);
  });
 
  document.getElementById('page-feed')?.addEventListener('click', (e) => {
    const card = e.target.closest('.article-card');
    if (card) {
      const articleId = card.dataset.id;
      const related = appViewModel.feed.items
        .filter((i) => i.isArticle)
        .map((i) => i.article)
        .find((a) => a.id === articleId);
 
      if (related) renderArticleDetail(related, _sourcePage);
    }
  });
}
 
function goBack() {
  const allPages = document.querySelectorAll('.page');
  allPages.forEach((p) => p.classList.remove('active'));
 
  const targetPage = document.getElementById(`page-${_sourcePage}`);
  if (targetPage) targetPage.classList.add('active');
}