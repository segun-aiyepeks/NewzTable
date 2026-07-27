import 'package:flutter/material.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
import 'package:newztable/model/feed_item_model.dart';

enum FeedState { idle, loading, loadingMore, success, error }

class FeedViewModel extends ChangeNotifier {
  FeedState _state = FeedState.idle;
  List<FeedItemModel> _feedItems = [];
  String _errorMessage = '';
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isRefreshing = false;

  FeedState get state => _state;
  List<FeedItemModel> get feedItems => _feedItems;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get isRefreshing => _isRefreshing;
  bool get isEmpty => _feedItems.isEmpty && _state == FeedState.success;

  Future<void> fetchFeed({bool refresh = false}) async {
    if(refresh) {
      _currentPage = 1;
      _hasMore = true;
      _isRefreshing = true;
      _feedItems = [];
      notifyListeners();
    } else {
      if(_state == FeedState.loading || _state == FeedState.loadingMore) {
        return;
      }
      _setState(_feedItems.isEmpty ? FeedState.loading : FeedState.loadingMore);
    }

    try {
      final response = await ApiClient.get(
        AppConstants.feedEndpoint,
        queryParameters: {
          'page': _currentPage,
          'limit': AppConstants.feedPageSize
        },
      );

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> items = data['items'] as List<dynamic>;
      final bool hasMore = data['hasMore'] as bool;

      final newItems = items
        .map((json) => FeedItemModel.fromJson(json as Map<String, dynamic>))
        .toList();

      if(refresh) {
        _feedItems = newItems;
      } else {
        _feedItems = [..._feedItems, ...newItems];
      }

      _hasMore = hasMore;
      _currentPage++;
      _isRefreshing = false;
      _setState(FeedState.success);
    } catch(e) {
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