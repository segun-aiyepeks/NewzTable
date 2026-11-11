import 'package:flutter/material.dart';
import 'package:newztable/core/network/news_api_service.dart';
import 'package:newztable/model/article_model.dart';
import 'package:newztable/model/feed_item_model.dart';

enum FeedState { idle, loading, loadingMore, success, error }

class FeedViewModel extends ChangeNotifier {
  FeedState _state = FeedState.idle;
  List<FeedItemModel> _feedItems = [];
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isRefreshing = false;

  // Selected category filter (All, Sports, Politics, Business, Health, Travel, Science)
  String _selectedCategory = 'all';

  // Available categories matching the Kabar inspiration UI
  final List<String> _categories = const [
    'All',
    'Sports',
    'Politics',
    'Business',
    'Health',
    'Travel',
    'Science',
    'Technology',
  ];

  FeedState get state => _state;
  List<FeedItemModel> get feedItems => _feedItems;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isRefreshing => _isRefreshing;
  bool get isEmpty => _feedItems.isEmpty && _state == FeedState.success;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;

  // Convenience getter for the featured/trending articles
  List<ArticleModel> get trendingArticles {
    return _feedItems
        .where((item) => item.isArticle && item.article != null)
        .map((item) => item.article!)
        .toList();
  }

  // Convenience getter for latest news list
  List<FeedItemModel> get latestItems {
    return _feedItems;
  }

  void selectCategory(String category) {
    if (_selectedCategory.toLowerCase() == category.toLowerCase()) return;
    _selectedCategory = category;
    notifyListeners();
    fetchFeed(refresh: true);
  }

  Future<void> fetchFeed({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _isRefreshing = true;
      notifyListeners();
    } else {
      if (_state == FeedState.loading || _state == FeedState.loadingMore) {
        return;
      }
      _setState(_feedItems.isEmpty ? FeedState.loading : FeedState.loadingMore);
    }

    try {
      final items = await NewsApiService.fetchFeed(
        category: _selectedCategory,
        page: _currentPage,
        limit: 20,
      );

      if (refresh) {
        _feedItems = items;
      } else {
        _feedItems = [..._feedItems, ...items];
      }

      _hasMore = items.length >= 10;
      _currentPage++;
      _isRefreshing = false;
      _setState(FeedState.success);
    } catch (e) {
      _isRefreshing = false;
      _errorMessage = e.toString();
      _setState(FeedState.error);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _state == FeedState.loadingMore) return;
    await fetchFeed();
  }

  Future<void> refresh() async {
    await fetchFeed(refresh: true);
  }

  void _setState(FeedState state) {
    _state = state;
    notifyListeners();
  }
}
