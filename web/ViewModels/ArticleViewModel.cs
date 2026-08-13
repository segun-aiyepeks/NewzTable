using web.Models;
using web.Services;

namespace web.ViewModels
{
    public enum ArticleState { Idle, Loading, Success, Error}
    public class ArticleViewModel
    {
        private readonly ApiService _apiService;

        public ArticleState State { get; private set; } = ArticleState.Idle;
        public ArticleModel? CurrentArticle { get; private set; }
        public List<ArticleModel> RelatedArticles { get; private set; } = new();
        public string ErrorMessage { get; private set; } = string.Empty;
        public bool IsBookmarked { get; private set; }

        public event Action? OnChange;

        public ArticleViewModel(ApiService apiService)
        {
            _apiService = apiService;
        }
        public async Task FetchArticleAsync(string articleId)
        {
            SetState(ArticleState.Loading);
            try
            {
                var (article, related) = await _apiService.GetArticleAsync(articleId);
                CurrentArticle = article;
                RelatedArticles = related;
                SetState(ArticleState.Success);

            } catch(Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(ArticleState.Error);
            }
        }
        public void SetArticle(ArticleModel article, bool isBookmarked)
        {
            CurrentArticle = article;
            IsBookmarked = isBookmarked;
            NotifyStateChanged();
        }

        public async Task ToggleBookmarkAsync(string articleId)
        {
            var wasBookmarked = IsBookmarked;
            IsBookmarked = !IsBookmarked;
            NotifyStateChanged();

            try
            {
                if(wasBookmarked)
                {
                    await _apiService.RemoveBookmarkAsync(articleId);
                }
                else
                {
                    await _apiService.AddBookmarkAsync(articleId);
                }
            } catch
            {
                IsBookmarked = wasBookmarked;
                NotifyStateChanged();
            }
        }
        public void SetBookmarkStatus(bool isBookmarked)
        {
            IsBookmarked = isBookmarked;
            NotifyStateChanged();
        }

        public void Reset()
        {
            CurrentArticle = null;
            RelatedArticles = new List<ArticleModel>();
            IsBookmarked = false;
            ErrorMessage = string.Empty;
            State = ArticleState.Idle;
        }

        private void SetState(ArticleState state)
        {
            State = state;
            NotifyStateChanged();
        }
        private void NotifyStateChanged() => OnChange?.Invoke();
    }
}
