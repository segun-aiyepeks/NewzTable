using System.Text.Json;

namespace web.Models
{
    public enum FeedItemType
    {
        Article, 
        Ad
    }
    public class FeedItemModel
    {
        public FeedItemType Type { get; private set; }
        public ArticleModel? Article { get; private set; }
        public string? SlotId { get; private set; }

        public bool IsArticle => Type == FeedItemType.Article;
        public bool IsAd => Type == FeedItemType.Ad;

        private FeedItemModel() { }

        public static FeedItemModel FromArticle(ArticleModel article)
        {
            return new FeedItemModel
            {
                Type = FeedItemType.Article,
                Article = article
            };

        }


        public static FeedItemModel FromAd(string slotId)
        {
            return new FeedItemModel
            {
                Type = FeedItemType.Ad,
                SlotId = slotId
            };
        }

        public static FeedItemModel FromJson(JsonElement json)
        {
            var type = json.GetProperty("type").GetString();

            if (type == "ad")
            {
                var slotId = json.GetProperty("slotId").GetString() ?? string.Empty;
                return FromAd(slotId);
            }

            var articleJson = json.GetProperty("data");
            var article = JsonSerializer.Deserialize<ArticleModel>(
                articleJson.GetRawText(),
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true }
            ) ?? new ArticleModel();

            return FromArticle(article);
        }
    }

    public class FeedResponse
    {
        public int Page { get; set; }
        public int Limit { get; set; }
        public int Total { get; set; }
        public bool HasMore { get; set; }
        public List<JsonElement> Items { get; set; } = new();
    }
}
