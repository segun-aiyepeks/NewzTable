using System.Text.Json.Serialization;

namespace web.Models
{
    public class ArticleModel
    {
        [JsonPropertyName("_id")]
        public string Id { get; set; } = string.Empty;
        public string Topic { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public string Url { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public string SourceName { get; set; } = string.Empty;
        public string Language { get; set; } = "en";
        public DateTime PublishedAt { get; set; }
    }
}
