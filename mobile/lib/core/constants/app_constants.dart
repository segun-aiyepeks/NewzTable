class AppConstants{
  AppConstants._();

  // Base Url of the Express backend
  static const String baseUrl = 'http://192.168.1.146:5000';

  // SharedPreferences keys
  static const String deviceIdKey = 'device_id';
  static const String topicsKey = 'selected_topics';
  static const String darkModeKey = 'dark_mode';

  // API endpoints
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