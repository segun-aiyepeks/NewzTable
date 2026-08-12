using web.Models;
using web.Services;

namespace web.ViewModels
{
    public enum TopicState { Idle, Loading, Success, Error}
    public class TopicViewModel
    {
        private readonly ApiService _apiService;
        private readonly LocalStorageService _localStorage;

        public TopicState State { get; private set; } = TopicState.Idle;
        public List<TopicModel> AvailableTopics { get; private set; } = new();
        public List<TopicModel> SelectedTopics { get; private set; } = new();
        public string ErrorMessage { get; private set; } = string.Empty;
        public bool HasEnoughTopics => SelectedTopics.Count >= 3;

        public event Action? onChange;

        public TopicViewModel(ApiService apiService, LocalStorageService localStorage)
        {
            _apiService = apiService;
            _localStorage = localStorage;
        }

        public async Task FetchAvailableTopicsAsync()
        {
            SetState(TopicState.Loading);
            
            try
            {
                AvailableTopics = await _apiService.GetTopicsAsync();
                SetState(TopicState.Success);
            } catch (Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(TopicState.Error);
            }
        }
        public async Task LoadSelectedTopicsAsync()
        {
            var savedKeys = await _localStorage.GetSelectedTopicsAsync();
            SelectedTopics = AvailableTopics.Where(t => savedKeys.Contains(t.Key)).ToList();
            NotifyStateChanged();
        }
        public void ToggleTopic(TopicModel topic)
        {
            if (SelectedTopics.Any(t => t.Key == topic.Key))
            {
                SelectedTopics = SelectedTopics.Where(t => t.Key != topic.Key).ToList();
            }else
            {
                SelectedTopics = new List<TopicModel>(SelectedTopics) { topic };
            }
            NotifyStateChanged();
        }
        public bool isSelected(TopicModel topic)
        {
            return SelectedTopics.Any(t => t.Key == topic.Key);
        }

        public async Task<bool> SaveSelectedTopicsAsync()
        {
            if (!HasEnoughTopics)
            {
                ErrorMessage = "Please select at least 3 topics";
                SetState(TopicState.Error);
                return false;
            }
            SetState(TopicState.Loading);

            try
            {
                var topicKeys = SelectedTopics.Select(t => t.Key).ToList();
                await _localStorage.SaveSelectedTopicsAsync(topicKeys);
                await _apiService.UpdateTopicsAsync(topicKeys);
                SetState(TopicState.Success);
                return true;

            } catch (Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(TopicState.Error);
                return false;
            }
        }
        public async Task<bool> InitUserAsync(string deviceId)
        {
            if (!HasEnoughTopics)
            {
                ErrorMessage = "Please select at least 3 topics";
                SetState(TopicState.Error);
                return false;
            }
            SetState(TopicState.Loading);
            
            try
            {
                var topicKeys = SelectedTopics.Select(t => t.Key).ToList();
                await _apiService.InitUserAsync(deviceId, topicKeys);
                SetState(TopicState.Success);
                return true;
            } catch(Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(TopicState.Error);
                return false;
            }
        }
        private void SetState(TopicState state)
        {
            state = State;
            NotifyStateChanged();
        }
        private void NotifyStateChanged() => onChange?.Invoke();
    }
}
