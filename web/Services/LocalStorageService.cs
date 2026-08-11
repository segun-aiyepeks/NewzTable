using Microsoft.JSInterop;

namespace web.Services
{
    public class LocalStorageService
    {
        private readonly IJSRuntime _jsRuntime;
        public LocalStorageService(IJSRuntime jsRuntime)
        {
            _jsRuntime = jsRuntime;
        }
        public async Task SetItemAsync(string key, string value)
        {
            await _jsRuntime.InvokeVoidAsync("localStorage.setItem", key, value);
        }
        public async Task<string?> GetItemsAsync(string key)
        {
            return await _jsRuntime.InvokeAsync<string?>("localStorage.getItem", key);
        }
        public async Task RemoveItemAsync(string key)
        {
            await _jsRuntime.InvokeVoidAsync(
                "localStorage.removeItem", key
            );
        }
        public async Task ClearAsync()
        {
            await _jsRuntime.InvokeVoidAsync("localStorage.clear");
        }
        public async Task<string> GetOrCreateDeviceIdAsync()
        {
            var deviceId = await GetItemsAsync("device_id");
            if (string.IsNullOrEmpty(deviceId))
            {
                deviceId = Guid.NewGuid().ToString();
                await SetItemAsync("device_id", deviceId);
            }
            return deviceId;
        }
        public async Task<List<string>> GetSelectedTopicsAsync()
        {
            var topics = await GetItemsAsync("selected_topics");
            if (string.IsNullOrEmpty(topics)) return new List<string>();

            return topics.Split(',').ToList();
        }
        public async Task SaveSelectedTopicsAsync(List<string> topics)
        {
            await SetItemAsync("selected_topics", string.Join(',', topics));
        }
        public async Task<bool> GetDarkModeAsync()
        {
            var value = await GetItemsAsync("dark_mode");
            return value == "true";
        }
        public async Task SaveDarkModeAsync(bool isDarkMode)
        {
            await SetItemAsync("dark_mode", isDarkMode.ToString().ToLower());
        }
        public async Task<bool> IsOnboardedAsync()
        {
            var topics = await GetSelectedTopicsAsync();
            return topics.Count > 0;
        }
    }
}
