enum NewsApiProvider {
  freeRssFeeds, // 100% Free BBC/CNN/TechCrunch/Google News feeds via RSS2JSON (No API Key needed)
  localBackend, // Custom Express backend (http://192.168.1.146:5000 or custom)
  theGuardian,  // The Guardian Open Platform (5000 requests/day, can use 'test' key)
  newsApiOrg,   // NewsAPI.org (100 req/day developer plan)
}

class AppConstants {
  AppConstants._();

  // Active News Provider: default to freeRssFeeds so it works immediately without setup
  static NewsApiProvider activeProvider = NewsApiProvider.freeRssFeeds;

  // Base Url of the Express backend (if running local server)
  static const String baseUrl = 'http://192.168.1.146:5000';

  // Free News API Keys (users can insert their own keys in Settings or here)
  static const String guardianApiKey = 'test'; // Guardian allows 'test' key out of the box
  static const String newsApiKey = ''; // Insert NewsAPI.org key if used

  // Free RSS Feed mappings (direct or via rss2json converter)
  static const String rssToJsonBaseUrl = 'https://api.rss2json.com/v1/api.json';

  static const Map<String, String> categoryRssFeeds = {
    'all': 'http://feeds.bbci.co.uk/news/rss.xml',
    'world': 'http://feeds.bbci.co.uk/news/world/rss.xml',
    'sports': 'http://feeds.bbci.co.uk/sport/rss.xml',
    'politics': 'http://feeds.bbci.co.uk/news/politics/rss.xml',
    'business': 'http://feeds.bbci.co.uk/news/business/rss.xml',
    'health': 'http://feeds.bbci.co.uk/news/health/rss.xml',
    'travel': 'https://www.huffpost.com/section/travel/feed',
    'science': 'http://feeds.bbci.co.uk/news/science_and_environment/rss.xml',
    'technology': 'http://feeds.bbci.co.uk/news/technology/rss.xml',
  };

  // SharedPreferences keys
  static const String deviceIdKey = 'device_id';
  static const String topicsKey = 'selected_topics';
  static const String darkModeKey = 'dark_mode';
  static const String newsProviderKey = 'news_provider_type';

  // API endpoints for local Express backend
  static const String initUserEndpoint = '/api/users/init';
  static const String currentUserEndpoint = '/api/users/me';
  static const String updateTopicsEndpoint = '/api/users/topics';
  static const String updatePreferencesEndpoint = '/api/users/preferences';
  static const String topicsEndpoint = '/api/articles/topics';
  static const String feedEndpoint = '/api/articles/feed';
  static const String searchEndpoint = '/api/articles/search';
  static const String bookmarksEndpoint = '/api/bookmarks';

  // Feed settings
  static const int feedPageSize = 20;

  // App info
  static const String appName = 'NewzTable';
  static const String appVersion = '1.0.0';
}
