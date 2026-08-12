using web.Services;

namespace web.ViewModels
{
    public class AppStateViewModel
    {
        private readonly LocalStorageService _localStorage;
        private readonly ApiService _apiService;

        public bool IsOnboarded { get; private set; }
        public bool IsDarkMode { get; private set; }
        public string DeviceId { get; private set; } = string.Empty;
        public bool IsInitialized { get; private set; }

        public event Action? OnChange;
        
        public AppStateViewModel ( 
            LocalStorageService localStorage,
            ApiService apiService
        )
        {
            _localStorage = localStorage;
            _apiService = apiService;
        }

        public async Task InitializeAsync()
        {
            DeviceId = await _localStorage.GetOrCreateDeviceIdAsync();
            _apiService.SetDeviceId(DeviceId);

            IsOnboarded = await _localStorage.IsOnboardedAsync();
            IsDarkMode = await _localStorage.GetDarkModeAsync();
            IsInitialized = true;

            NotifyStateChanged();
        }
        public async Task CompleteOnboardingAsync(List<string> topics)
        {
            await _localStorage.SaveSelectedTopicsAsync(topics);
            IsOnboarded = true;
            NotifyStateChanged();
        }
        public async Task ClearLocalDataAsync()
        {
            await _localStorage.ClearAsync();
            IsOnboarded = false;
            IsDarkMode = false;
            DeviceId = string.Empty;
            NotifyStateChanged();
        }
        private void NotifyStateChanged() => OnChange?.Invoke();
    }
}
