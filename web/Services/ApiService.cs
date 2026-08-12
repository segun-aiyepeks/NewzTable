using System.Net.Http.Json;
using System.Text.Json;
using web.Models;

namespace web.Services
{
    public class ApiService
    {
        private readonly HttpClient _httpClient;
        private string _deviceId = string.Empty;

        private static readonly JsonSerializerOptions _jsonOptions = new()
        {
            PropertyNameCaseInsensitive = true
        };
        public ApiService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }
        public void SetDeviceId(string deviceId)
        {
            _deviceId = deviceId;
            _httpClient.DefaultRequestHeaders.Remove("X-Device-Id");
            _httpClient.DefaultRequestHeaders.Add("X-Device-Id", deviceId);
        }

        public async Task<List<TopicModel>> GetTopicsAsync()
        {
            var result = await _httpClient.GetFromJsonAsync<List<TopicModel>>("api/articles/topics", _jsonOptions);
            return result ?? new List<TopicModel>();
        }
        public async Task<FeedResponse> GetFeedAsync(int page = 1, int limit = 20)
        {
            var result = await _httpClient.GetFromJsonAsync<FeedResponse>(
                $"api/articles/feed?page={ page}&limit ={limit}",
                _jsonOptions
                );
            return result ?? new FeedResponse();
        }
       public async Task<(ArticleModel article, List<ArticleModel> related)> GetArticleAsync(string articleId)
        {
            var response = await _httpClient.GetAsync($"api/article/{articleId}");
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();
            var doc = JsonDocument.Parse(json);

            var article = JsonSerializer.Deserialize<ArticleModel>(
                doc.RootElement.GetProperty("article").GetRawText(),
                _jsonOptions
            ) ?? new ArticleModel();

            var related = JsonSerializer.Deserialize<List<ArticleModel>>(
                doc.RootElement.GetProperty("related").GetRawText(),
                _jsonOptions
            ) ?? new List<ArticleModel>();

            return (article, related);
        }
        public async Task<List<ArticleModel>> SearchArticlesAsync(
            string query, int page = 1, int limit = 20)
        {
            var encoded = Uri.EscapeDataString(query);
            var response = await _httpClient.GetFromJsonAsync<SearchResponse>(
                $"api/articles/search?q={encoded}&page={page}&limit={limit}",
                _jsonOptions
            );
            return response?.Items ?? new List<ArticleModel>();
        }
        public async Task<List<BookmarkModel>> GetBookmarksAsync()
        {
            var result = await _httpClient.GetFromJsonAsync<List<BookmarkModel>>(
                "api/bookmarks",
                _jsonOptions
            );
            return result ?? new List<BookmarkModel>();
        }
        public async Task AddBookmarkAsync(string articleId)
        {
            var response = await _httpClient.PostAsJsonAsync(
                "api/bookmarks",
                new { articleId }
            );
            response.EnsureSuccessStatusCode();
        }
        public async Task RemoveBookmarkAsync(string articleId)
        {
            var response = await _httpClient.DeleteAsync($"api/bookmarks/{articleId}");
            response.EnsureSuccessStatusCode();
        }
        public async Task InitUserAsync(string deviceId, List<string> topics)
        {
            var response = await _httpClient.PostAsJsonAsync(
                "api/users/init",
                new { deviceId, topics }
            );
            response.EnsureSuccessStatusCode();
        }
        public async Task UpdateTopicsAsync(List<string> topics)
        {
            var response = await _httpClient.PutAsJsonAsync("api/users/topics", new { topics });
            response.EnsureSuccessStatusCode();
        }
        public async Task UpdatePreferencesAsync(bool? darkMode = null, bool? pushEnabled = null)
        {
            var body = new Dictionary<string, object>();
            if (darkMode.HasValue) body["darkMode"] = darkMode.Value;
            if (pushEnabled.HasValue) body["pushEnabled"] = pushEnabled.Value;

            var response = await _httpClient.PutAsJsonAsync(
                "api/users/preferences", body
            );
            response.EnsureSuccessStatusCode();
        }
    }

    public class SearchResponse
    {
        public int Page { get; set; }
        public int Total { get; set; }
        public bool HasMore { get; set; }
        public List<ArticleModel> Items { get; set; } = new();
    }
}
