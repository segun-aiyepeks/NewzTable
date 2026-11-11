import 'package:dio/dio.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
import 'package:newztable/model/article_model.dart';
import 'package:newztable/model/feed_item_model.dart';

class NewsApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 12),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'NewzTable/1.0',
      },
    ),
  );

  /// Fetch feed items for a given category and page
  static Future<List<FeedItemModel>> fetchFeed({
    String category = 'all',
    int page = 1,
    int limit = 20,
    NewsApiProvider? providerOverride,
  }) async {
    final provider = providerOverride ?? AppConstants.activeProvider;

    try {
      switch (provider) {
        case NewsApiProvider.freeRssFeeds:
          return await _fetchFromRss(category: category, page: page, limit: limit);

        case NewsApiProvider.theGuardian:
          return await _fetchFromTheGuardian(category: category, page: page, limit: limit);

        case NewsApiProvider.newsApiOrg:
          return await _fetchFromNewsApi(category: category, page: page, limit: limit);

        case NewsApiProvider.localBackend:
          return await _fetchFromLocalBackend(page: page, limit: limit);
      }
    } catch (e) {
      // If network fails, return rich fallback data matching the design system
      return _getFallbackFeedItems(category: category);
    }
  }

  /// Search articles
  static Future<List<ArticleModel>> searchArticles(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];

    try {
      if (AppConstants.activeProvider == NewsApiProvider.localBackend) {
        final response = await ApiClient.get(
          AppConstants.searchEndpoint,
          queryParameters: {'q': query, 'page': page, 'limit': 20},
        );
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> items = data['items'] as List<dynamic>;
        return items.map((json) => ArticleModel.fromJson(json as Map<String, dynamic>)).toList();
      }

      // Try The Guardian search with free 'test' key
      final response = await _dio.get(
        'https://content.guardianapis.com/search',
        queryParameters: {
          'q': query,
          'api-key': AppConstants.guardianApiKey,
          'show-fields': 'thumbnail,trailText,headline,byline',
          'page': page,
          'page-size': 20,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final results = data['response']?['results'] as List<dynamic>? ?? [];
      return results.map((item) => ArticleModel.fromGuardian(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Filter fallback articles matching query
      final allFallback = _getFallbackArticles();
      return allFallback
          .where((art) =>
              art.title.toLowerCase().contains(query.toLowerCase()) ||
              art.description.toLowerCase().contains(query.toLowerCase()) ||
              art.topic.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // --- RSS-to-JSON Provider (100% Free BBC/CNN Feeds) ---
  static Future<List<FeedItemModel>> _fetchFromRss({
    required String category,
    required int page,
    required int limit,
  }) async {
    final cleanCategory = category.toLowerCase().trim();
    final feedUrl = AppConstants.categoryRssFeeds[cleanCategory] ??
        AppConstants.categoryRssFeeds['all']!;

    final response = await _dio.get(
      AppConstants.rssToJsonBaseUrl,
      queryParameters: {
        'rss_url': feedUrl,
        'api_key': '', // Free tier requires no key
      },
    );

    final data = response.data as Map<String, dynamic>;
    if (data['status'] != 'ok') {
      throw Exception(data['message'] ?? 'Failed to fetch RSS feed');
    }

    final items = data['items'] as List<dynamic>? ?? [];
    final displayTopic = cleanCategory == 'all' ? 'World' : _capitalize(cleanCategory);

    final articles = items
        .map((item) => ArticleModel.fromRssJson(item as Map<String, dynamic>, defaultTopic: displayTopic))
        .toList();

    return articles.map((article) => FeedItemModel.article(article)).toList();
  }

  // --- The Guardian Open Platform Provider ---
  static Future<List<FeedItemModel>> _fetchFromTheGuardian({
    required String category,
    required int page,
    required int limit,
  }) async {
    final cleanCategory = category.toLowerCase().trim();
    final Map<String, dynamic> params = {
      'api-key': AppConstants.guardianApiKey,
      'show-fields': 'thumbnail,trailText,headline,byline',
      'page': page,
      'page-size': limit,
    };

    if (cleanCategory != 'all') {
      // Map common categories to Guardian sections
      String section = cleanCategory;
      if (cleanCategory == 'sports') section = 'sport';
      if (cleanCategory == 'health') section = 'society';
      params['section'] = section;
    }

    final response = await _dio.get(
      'https://content.guardianapis.com/search',
      queryParameters: params,
    );

    final data = response.data as Map<String, dynamic>;
    final results = data['response']?['results'] as List<dynamic>? ?? [];
    final articles = results
        .map((item) => ArticleModel.fromGuardian(item as Map<String, dynamic>))
        .toList();

    return articles.map((article) => FeedItemModel.article(article)).toList();
  }

  // --- NewsAPI.org Provider ---
  static Future<List<FeedItemModel>> _fetchFromNewsApi({
    required String category,
    required int page,
    required int limit,
  }) async {
    if (AppConstants.newsApiKey.isEmpty) {
      throw Exception('NewsAPI key is empty. Please set an API key in AppConstants.');
    }

    final cleanCategory = category.toLowerCase().trim();
    final Map<String, dynamic> params = {
      'apiKey': AppConstants.newsApiKey,
      'language': 'en',
      'pageSize': limit,
      'page': page,
    };

    if (cleanCategory != 'all') {
      params['category'] = cleanCategory;
    }

    final response = await _dio.get(
      'https://newsapi.org/v2/top-headlines',
      queryParameters: params,
    );

    final data = response.data as Map<String, dynamic>;
    final articlesJson = data['articles'] as List<dynamic>? ?? [];
    final articles = articlesJson
        .map((item) => ArticleModel.fromNewsApi(
              item as Map<String, dynamic>,
              defaultTopic: cleanCategory == 'all' ? 'General' : _capitalize(cleanCategory),
            ))
        .toList();

    return articles.map((article) => FeedItemModel.article(article)).toList();
  }

  // --- Local Express Backend Provider ---
  static Future<List<FeedItemModel>> _fetchFromLocalBackend({
    required int page,
    required int limit,
  }) async {
    final response = await ApiClient.get(
      AppConstants.feedEndpoint,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data as Map<String, dynamic>;
    final List<dynamic> items = data['items'] as List<dynamic>;

    return items
        .map((json) => FeedItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Fallback rich mock data styled after the inspiration screenshot
  static List<FeedItemModel> _getFallbackFeedItems({String category = 'all'}) {
    final articles = _getFallbackArticles();
    if (category.toLowerCase() != 'all') {
      final filtered = articles
          .where((a) => a.topic.toLowerCase() == category.toLowerCase())
          .toList();
      if (filtered.isNotEmpty) {
        return filtered.map((a) => FeedItemModel.article(a)).toList();
      }
    }
    return articles.map((a) => FeedItemModel.article(a)).toList();
  }

  static List<ArticleModel> _getFallbackArticles() {
    return [
      ArticleModel(
        id: 'kabar_1',
        topic: 'Europe',
        title: 'Russian warship: Moskva sinks in Black Sea after missile attack',
        description: 'Russia’s Black Sea flagship Moskva has sunk after being damaged during the military conflict in Ukraine.',
        content: 'Russia’s Black Sea flagship Moskva has sunk after being damaged during the military conflict in Ukraine. Ukraine claims its missiles struck the warship, while Russia said ammunition blew up.',
        url: 'https://www.bbc.com/news/world-europe-61114843',
        imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800&auto=format&fit=crop&q=80',
        sourceName: 'BBC News',
        language: 'en',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ArticleModel(
        id: 'kabar_2',
        topic: 'Europe',
        title: "Ukraine's President Zelensky to BBC: Blood money being paid for Russian oil",
        description: "President Zelensky singled out Germany and Hungary, accusing them of blocking efforts to embargo energy sales.",
        content: "Ukrainian President Volodymyr Zelensky has accused European countries that continue to buy Russian oil of earning their money in other people's blood.",
        url: 'https://www.bbc.com/news/world-europe-61101906',
        imageUrl: 'https://images.unsplash.com/photo-1526470608268-f674ce90ebd4?w=800&auto=format&fit=crop&q=80',
        sourceName: 'BBC News',
        language: 'en',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 14)),
      ),
      ArticleModel(
        id: 'kabar_3',
        topic: 'Travel',
        title: 'Her train broke down. Her phone died. And then she met her future husband',
        description: 'A missed connection on a delayed rail journey turned into an unexpected romance spanning three continents.',
        content: 'When Sarah boarded the overnight train, she had no idea a delayed locomotive would introduce her to the love of her life.',
        url: 'https://www.cnn.com/travel/article/train-breakdown-romance/index.html',
        imageUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&auto=format&fit=crop&q=80',
        sourceName: 'CNN',
        language: 'en',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ArticleModel(
        id: 'kabar_4',
        topic: 'Money',
        title: 'Wind power produced more electricity than coal and nuclear for first time',
        description: 'Renewable energy milestones surge as wind farms across Europe and the Americas outpace legacy power plants.',
        content: 'Clean energy generation set a new historical record this month as wind power output exceeded traditional coal plants.',
        url: 'https://www.usatoday.com/money/renewable-energy-record',
        imageUrl: 'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=800&auto=format&fit=crop&q=80',
        sourceName: 'USA Today',
        language: 'en',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ArticleModel(
        id: 'kabar_5',
        topic: 'Life',
        title: 'We keep rising to new challenges: Inside communities rebuilding heritage',
        description: 'How local towns are breathing vibrant culture back into historic architecture and sacred monuments.',
        content: 'Communities across the nation are uniting to restore beloved historical landmarks and community squares.',
        url: 'https://www.usatoday.com/life/heritage-restoration',
        imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&auto=format&fit=crop&q=80',
        sourceName: 'USA Today',
        language: 'en',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ArticleModel(
        id: 'kabar_6',
        topic: 'Technology',
        title: 'Next-generation AI chips reshape mobile edge computing and smartphones',
        description: 'New neural architectures allow deep neural nets to run entirely on-device with zero latency.',
        content: 'Major chipmakers have announced 2nm process technology designed specifically for local generative models.',
        url: 'https://www.theverge.com/tech/ai-chips-breakthrough',
        imageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&auto=format&fit=crop&q=80',
        sourceName: 'The Verge',
        language: 'en',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      ArticleModel(
        id: 'kabar_7',
        topic: 'Sports',
        title: 'Champions League dramatic comeback thrills football fans worldwide',
        description: 'Two stoppage-time goals seal a legendary victory in one of European football’s most thrilling fixtures.',
        content: 'The underdogs produced a tactical masterclass in the final ten minutes to secure a spot in the finals.',
        url: 'https://www.bbc.com/sport/football',
        imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800&auto=format&fit=crop&q=80',
        sourceName: 'BBC Sport',
        language: 'en',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }
}
