import { escapeHtml, timeAgo } from '../utils/helpers.js';
 
/**
 * Renders a single article card HTML string.
 */
export function articleCardHTML(article, { isBookmarked = false, showBookmark = true } = {}) {
  const bookmarkIcon = isBookmarked ? 'bi-bookmark-fill' : 'bi-bookmark';
  const bookmarkClass = isBookmarked ? 'bookmarked' : '';
 
  return `
    <div class="article-card" data-id="${escapeHtml(article.id)}">
      <div class="article-card-body">
        <div class="article-meta">
          <span class="article-source">${escapeHtml(article.sourceName)}</span>
          <span class="article-dot"></span>
          <span class="article-time">${timeAgo(article.publishedAt)}</span>
        </div>
        <h3 class="article-title">${escapeHtml(article.title)}</h3>
        <div class="article-footer">
          <span class="topic-badge">${escapeHtml(article.topicLabel)}</span>
          ${showBookmark ? `
            <button class="btn-bookmark ${bookmarkClass}"
              data-bookmark-id="${escapeHtml(article.id)}"
              aria-label="${isBookmarked ? 'Remove bookmark' : 'Save article'}">
              <i class="bi ${bookmarkIcon}"></i>
            </button>
          ` : ''}
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
 
/**
 * Renders a shimmer loading card.
 */
export function shimmerCardHTML() {
  return `
    <div class="shimmer-card">
      <div style="flex:1">
        <div style="display:flex;gap:8px;margin-bottom:10px">
          <div class="shimmer-line" style="width:80px;height:11px"></div>
          <div class="shimmer-line" style="width:50px;height:11px"></div>
        </div>
        <div class="shimmer-line" style="width:100%;height:13px;margin-bottom:7px"></div>
        <div class="shimmer-line" style="width:100%;height:13px;margin-bottom:7px"></div>
        <div class="shimmer-line" style="width:60%;height:13px;margin-bottom:14px"></div>
        <div class="shimmer-line" style="width:72px;height:22px;border-radius:99px"></div>
      </div>
      <div class="shimmer-line"
        style="width:96px;height:96px;border-radius:8px;flex-shrink:0"></div>
    </div>
  `;
}
 
/**
 * Renders multiple shimmer cards.
 */
export function shimmerListHTML(count = 6) {
  return Array.from({ length: count }, shimmerCardHTML).join('');
}
 
/**
 * Renders an ad slot placeholder card.
 */
export function adCardHTML(slotId) {
  return `
    <div class="ad-card">
      <div class="ad-label-wrap">
        <span class="ad-label">Sponsored</span>
      </div>
      <div class="ad-body">
        <i class="bi bi-megaphone"></i>
        <span>Advertisement</span>
        <span style="font-size:10px;opacity:0.5">${escapeHtml(slotId)}</span>
      </div>
    </div>
  `;
}
 
/**
 * Renders an error state view.
 */
export function errorViewHTML({
  message = 'Something went wrong',
  icon = 'bi-wifi-off',
  retryId = 'retryBtn',
} = {}) {
  return `
    <div class="state-view">
      <div class="state-icon danger">
        <i class="bi ${escapeHtml(icon)}"></i>
      </div>
      <p class="state-title">Something went wrong</p>
      <p class="state-message">${escapeHtml(message)}</p>
      <button class="btn-primary" id="${escapeHtml(retryId)}">
        <i class="bi bi-arrow-clockwise"></i> Try Again
      </button>
    </div>
  `;
}
 
/**
 * Renders an empty state view.
 */
export function emptyViewHTML({
  title = 'Nothing here yet',
  message = '',
  icon = 'bi-inbox',
  actionLabel = null,
  actionId = null,
} = {}) {
  return `
    <div class="state-view">
      <div class="state-icon primary">
        <i class="bi ${escapeHtml(icon)}"></i>
      </div>
      <p class="state-title">${escapeHtml(title)}</p>
      ${message ? `<p class="state-message">${escapeHtml(message)}</p>` : ''}
      ${actionLabel && actionId ? `
        <button class="btn-primary" id="${escapeHtml(actionId)}">
          ${escapeHtml(actionLabel)}
        </button>
      ` : ''}
    </div>
  `;
}
 
/**
 * Renders a load more button.
 */
export function loadMoreHTML(id = 'loadMoreBtn') {
  return `
    <div class="load-more-wrap">
      <button class="btn-outline" id="${escapeHtml(id)}">
        <i class="bi bi-arrow-down-circle"></i> Load More
      </button>
    </div>
  `;
}
 
/**
 * Renders a "you're all caught up" message.
 */
export function caughtUpHTML() {
  return `<p class="caught-up">✓ You're all caught up!</p>`;
}
 
/**
 * Renders a back button.
 */
export function backButtonHTML(id = 'backBtn', label = 'Back') {
  return `
    <button class="btn-back" id="${escapeHtml(id)}">
      <i class="bi bi-arrow-left"></i>
      ${escapeHtml(label)}
    </button>
  `;
}