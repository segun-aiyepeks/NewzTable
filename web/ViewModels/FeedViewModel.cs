using web.Models;
using web.Services;

namespace web.ViewModels
{
    public enum FeedState { Idle, Loading, LoadingMore, Success, Error }
    public class FeedViewModel
    {
        private readonly ApiService _apiService;

        public FeedState State { get; private set; } = FeedState.Idle;
        public List<FeedItemModel> FeedItems { get; private set; } = new();
        public string ErrorMessage { get; private set; } = string.Empty;
        public bool HasMore { get; private set; } = true;
        public bool IsRefreshing { get; private set; }
        public bool IsEmpty => FeedItems.Count == 0 & State == FeedState.Success;

        private int _currentPage = 1;
        public event Action? OnChange;
        
        public FeedViewModel(ApiService apiService)
        {
            _apiService = apiService;
        }

        public async Task FetchFeedAsync(bool refresh = false)
        {
            if (refresh)
            {
                _currentPage = 1;
                HasMore = true;
                IsRefreshing = true;
                FeedItems = new List<FeedItemModel>();
                NotifyStateChanged();
            }
            else
            {
                if (State == FeedState.Loading || State == FeedState.LoadingMore) return;

                SetState(FeedItems.Count == 0 ? FeedState.Loading : FeedState.LoadingMore);
            }

            try
            {
                var response = await _apiService.GetFeedAsync(_currentPage);
                var newItems = response.Items.Select(item => FeedItemModel.FromJson(item)).ToList();

                if (refresh)
                {
                    FeedItems = newItems;
                }
                else
                {
                    FeedItems = new List<FeedItemModel>(FeedItems);
                    FeedItems.AddRange(newItems);
                }
            }
            catch (Exception ex)
            {
                IsRefreshing = false;
                ErrorMessage = ex.Message;
                SetState(FeedState.Error);
            }
        }
        public async Task LoadMoreAsync() {
            if (!HasMore || State == FeedState.LoadingMore) return;
            await FetchFeedAsync();
        }
        public async Task RefreshAsync() {
            await FetchFeedAsync(refresh: true);
        }
        private void SetState(FeedState state)
        {
            State = state;
            NotifyStateChanged();
        }
        private void NotifyStateChanged() => OnChange?.Invoke();
    }
}
