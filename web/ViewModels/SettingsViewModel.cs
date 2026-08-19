using web.Services;

namespace web.ViewModels
{
    public enum SettingsState { Idle, Loading, Success, Empty, Error }
    public class SettingsViewModel
    {
        private readonly LocalStorageService _localStorage;
        private readonly AppStateViewModel _appState;

        public SettingsState State { get; private set; } = SettingsState.Idle;
        public string DeviceId { get; private set; } = string.Empty;
        public string ErrorMessage { get; private set; } = string.Empty;

        public bool isDarkMode => _appState.IsDarkMode;
        public event Action? onChange;

        public SettingsViewModel(
            LocalStorageService localStorage,
            AppStateViewModel appState
        )
        {
            _localStorage = localStorage;
            _appState = appState;
            _appState.OnChange += NotifyStateChanged;
        }
        public async Task LoadSettingsAsync()
        {
            SetState(SettingsState.Loading);
            
            try
            {
                DeviceId = await _localStorage.GetItemsAsync("device_id") ?? string.Empty;
                SetState(SettingsState.Success);
            } catch (Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(SettingsState.Error);
            }
        }
        public async Task ToggleDarkModeAsync()
        {
            await _appState.ToggleDarkModeAsync();
        }
        public async Task ClearLocalDataAsync()
        {
            SetState(SettingsState.Loading);

            try
            {
                await _appState.ClearLocalDataAsync();
                DeviceId = string.Empty;
                SetState(SettingsState.Success);
            } catch(Exception ex)
            {
                ErrorMessage = ex.Message;
                SetState(SettingsState.Error);
            }
        }

        private void SetState(SettingsState state)
        {
            State = state;
            NotifyStateChanged();
        }
        private void NotifyStateChanged() => onChange?.Invoke();
    }
}
