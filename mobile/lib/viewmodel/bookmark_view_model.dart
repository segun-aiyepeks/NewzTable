import 'package:flutter/widgets.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
import 'package:newztable/model/bookmark_model.dart';

enum BookmarkState { idle, loading, success, error }

class BookmarkViewModel extends ChangeNotifier {
  BookmarkState _state = BookmarkState.idle;
  List<BookmarkModel> _bookmarks = [];
  String _errorMessage = '';

  BookmarkState get state => _state;
  List<BookmarkModel> get bookmarks => _bookmarks;
  String get errorMessage => _errorMessage;
  bool get isEmpty => _bookmarks.isEmpty;
  
  Future<void> fetchBookmarks() async {
    _setState(BookmarkState.loading);

    try {
      final response = await ApiClient.get(AppConstants.bookmarksEndpoint);
      final List<dynamic> data = response.data as List<dynamic>;

      _bookmarks = data
        .map((json) => BookmarkModel.fromJson(json as Map<String, dynamic>))
        .toList();
      
      _setState(BookmarkState.success);
    } catch(e) {
      _errorMessage = e.toString();
      _setState(BookmarkState.error);
    }
  }

  Future<void> removeBookmarks(String articleId) async {
    final removedBookmark = _bookmarks.where(
      (b) => b.article.id != articleId).toList();
    notifyListeners();

    try {
      await ApiClient.delete(
        '${AppConstants.bookmarksEndpoint}/$articleId'
      );
    } catch(e) {
      _bookmarks = [..._bookmarks, ...removedBookmark];
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  bool isBookmarked(String articleId) {
    return _bookmarks.any((b) => b.article.id == articleId);
  }

  void _setState(BookmarkState state) {
    _state = state;
    notifyListeners();
  }
}