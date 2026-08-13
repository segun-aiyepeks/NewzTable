using web.Models;
using web.Services;

namespace web.ViewModels
{
    public enum BookmarkState { Idle, Loading, Success, Error }
    public class BookmarkViewModel
    {
        private readonly ApiService _apiService;

        public BookmarkState State { get; private set; } = BookmarkState.Idle;
        public List<BookmarkModel> Bookmarks { get; private set; } = new();
        public string ErrorMessage { get; private set; } = string.Empty;
        public bool IsEmpty => Bookmarks.Count == 0 && State == BookmarkState.Success;

        public event Action? OnChange;

        public BookmarkViewModel(ApiService apiService)
        {
            _apiService = apiService;
        }

        public async Task FetchBookmarksAsync()
        {
            SetState(BookmarkState.Loading);

            try
            {
                Bookmarks = await _apiService.GetBookmarksAsync();
                SetState(BookmarkState.Success);
            } catch(Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(BookmarkState.Error);
            }
        }
        public async Task RemoveBookmarkAsync(string articleId)
        {
            var removed = Bookmarks.FirstOrDefault(b => b.Article.Id == articleId);
            if (removed == null) return;

            Bookmarks = Bookmarks.Where(b => b.Article.Id != articleId).ToList();
            NotifyStateChanged();

            try
            {
                await _apiService.RemoveBookmarkAsync(articleId);
            }
            catch
            {
                Bookmarks = new List<BookmarkModel>(Bookmarks) { removed };
                NotifyStateChanged();
            }
        }
        public async Task AddBookmarkAsync(string articleId)
        {
            try
            {
                await _apiService.AddBookmarkAsync(articleId);
                await FetchBookmarksAsync();
            } catch(Exception ex)
            {
                ErrorMessage = ex.Message;
                NotifyStateChanged();
            }
        }
        public bool IsBookmarked(string articleId)
        {
            return Bookmarks.Any(b => b.Article.Id == articleId);
        }

        private void SetState(BookmarkState state)
        {
            State = state;
            NotifyStateChanged();
        }
        private void NotifyStateChanged() => OnChange?.Invoke();
    }
}
