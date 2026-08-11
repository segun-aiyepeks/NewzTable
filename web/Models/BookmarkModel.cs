namespace web.Models
{
    public class BookmarkModel
    {
        public string BookmarkdId { get; set; } = string.Empty;
        public DateTime SavedAt { get; set; }
        public ArticleModel Article { get; set; }
    }
}
