import 'package:flutter/widgets.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
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

    if(trimmed.isEmpty) {
      _results = [];
      _setState(SearchState.idle);
      return;
    }

    if(trimmed == _lastQuery && _state == SearchState.success) return;
    
    _lastQuery = trimmed;
    _currentPage = 1;
    _hasMore = true;
    _results = [];
    _setState(SearchState.loading);

    try {
      final response = await ApiClient.get(
        AppConstants.searchEndpoint,
        queryParameters: {
          'q': trimmed,
          'page': _currentPage,
          'limit': AppConstants.feedPageSize
        }
      );

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> items = data['items'] as List<dynamic>;
      final bool hasMore = data['hasMore'] as bool;

      _results = items
        .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
        .toList();
      
      _hasMore = hasMore;
      _currentPage++;
      _setState(SearchState.success);
    } catch(e) {
      _errorMessage = e.toString();
      _setState(SearchState.error);
    }
  }

  Future<void> loadMore() async {
    if(!_hasMore || _state == SearchState.loading) return;
    _setState(SearchState.loading);

    try {
      final response = await ApiClient.get(
        AppConstants.searchEndpoint,
        queryParameters: {
          'q': _lastQuery,
          'page': _currentPage,
          'limit': AppConstants.feedPageSize
        }
      );

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> items = data['items'] as List<dynamic>;
      final bool hasMore = data['hasMore'] as bool;

      final newResults = items.map((json) => ArticleModel.fromJson(json as Map<String, dynamic>)).toList();

      _results = [..._results, ...newResults];
      _hasMore = hasMore;
      _currentPage++;

      _setState(SearchState.success);
    } catch(e) {
      _errorMessage = e.toString();
      _setState(SearchState.error);
    }
  }

  void clearSearch() {
    _results = [];
    _lastQuery = '';
    _currentPage = 1;
    _hasMore = true;
    _setState(SearchState.idle);
  }

  void _setState(SearchState state) {
    _state = state;
    notifyListeners();
  }
}