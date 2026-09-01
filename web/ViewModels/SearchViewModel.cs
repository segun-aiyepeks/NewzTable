using web.Models;
using web.Services;

namespace web.ViewModels
{
    public enum SearchState { Idle, Loading, Success, Empty, Error }
    public class SearchViewModel
    {
        private readonly ApiService _apiService;

        public SearchState State { get; private set; } = SearchState.Idle;
        public List<ArticleModel> Results { get; private set; } = new();
        public string ErrorMessage { get; private set; } = string.Empty;
        public string LastQuery { get; private set; } = string.Empty;
        public bool HasMore { get; private set; } = true;

        private int _currentPage = 1;
        private CancellationTokenSource? _debounceToken;

        public event Action? OnChange;

        public SearchViewModel(ApiService apiService)
        {
            _apiService = apiService;
        }

        public async Task SearchAsync(string query)
        {
            var trimmed = query.Trim();

            if (string.IsNullOrEmpty(trimmed))
            {
                ClearSearch();
                return;
            }
            if (trimmed == LastQuery && State == SearchState.Success) return;

            _debounceToken?.Cancel();
            _debounceToken = new CancellationTokenSource();
            var token = _debounceToken.Token;

            try
            {
                await Task.Delay(500, token);
            }
            catch (TaskCanceledException)
            {
                return;
            }

            LastQuery = trimmed;
            _currentPage = 1;
            HasMore = true;
            Results = new List<ArticleModel>();
            SetState(SearchState.Loading);

            try
            {
                var results = await _apiService.SearchArticlesAsync(trimmed, _currentPage);
                Results = results;
                _currentPage++;
                SetState(Results.Count == 0 ? SearchState.Empty : SearchState.Success);

            } catch(Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(SearchState.Error);
            }
        }
        public async Task LoadMoreAsync()
        {
            if (!HasMore || State == SearchState.Loading) return;
            SetState(SearchState.Loading);
            try
            {
                var newResults = await _apiService.SearchArticlesAsync(LastQuery, _currentPage);
                Results = new List<ArticleModel>(Results);
                Results.AddRange(newResults);
                HasMore = newResults.Count > 0;
                _currentPage++;

                SetState(SearchState.Success);
            } catch(Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(SearchState.Error);
            }
        }

        public void ClearSearch()
        {
            _debounceToken?.Cancel();
            Results = new List<ArticleModel>();
            LastQuery = string.Empty;
            _currentPage = 1;
            HasMore = true;
            SetState(SearchState.Idle);
        }
        private void SetState(SearchState state)
        {
            State = state;
            NotifyStateChanged();
        }
        private void NotifyStateChanged() => OnChange?.Invoke(); 
    }
}
