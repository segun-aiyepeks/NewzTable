import 'package:flutter/widgets.dart';
import 'package:newztable/core/network/news_api_service.dart';
import 'package:newztable/model/article_model.dart';

enum SearchState { idle, loading, success, empty, error }

class SearchViewModel extends ChangeNotifier {
  SearchState _state = SearchState.idle;
  List<ArticleModel> _results = [];
  String _errorMessage = '';
  String _lastQuery = '';
  int _currentPage = 1;
  bool _hasMore = true;

  SearchState get state => _state;
  List<ArticleModel> get results => _results;
  String get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  Future<void> search(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      _results = [];
      _setState(SearchState.idle);
      return;
    }

    if (trimmed == _lastQuery && _state == SearchState.success) return;

    _lastQuery = trimmed;
    _currentPage = 1;
    _hasMore = true;
    _results = [];
    _setState(SearchState.loading);

    try {
      final items = await NewsApiService.searchArticles(trimmed, page: _currentPage);

      _results = items;
      _hasMore = items.length >= 10;
      _currentPage++;

      if (_results.isEmpty) {
        _setState(SearchState.empty);
      } else {
        _setState(SearchState.success);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _setState(SearchState.error);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _state == SearchState.loading) return;

    try {
      final items = await NewsApiService.searchArticles(_lastQuery, page: _currentPage);

      _results = [..._results, ...items];
      _hasMore = items.length >= 10;
      _currentPage++;

      _setState(SearchState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(SearchState.error);
    }
  }

  void clearSearch() {
    _results = [];
    _lastQuery = '';
    _setState(SearchState.idle);
  }

  void _setState(SearchState state) {
    _state = state;
    notifyListeners();
  }
}
