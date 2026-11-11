import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
import 'package:newztable/model/article_model.dart';
import 'package:newztable/model/bookmark_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BookmarkState { idle, loading, success, error }

class BookmarkViewModel extends ChangeNotifier {
  static const String _localBookmarksKey = 'local_saved_bookmarks';

  BookmarkState _state = BookmarkState.idle;
  List<BookmarkModel> _bookmarks = [];
  String _errorMessage = '';

  BookmarkState get state => _state;
  List<BookmarkModel> get bookmarks => _bookmarks;
  String get errorMessage => _errorMessage;
  bool get isEmpty => _bookmarks.isEmpty;

  Future<void> fetchBookmarks() async {
    _setState(BookmarkState.loading);

    // First load from local storage
    await _loadFromLocal();

    // If localBackend is active, try to sync from remote
    if (AppConstants.activeProvider == NewsApiProvider.localBackend) {
      try {
        final response = await ApiClient.get(AppConstants.bookmarksEndpoint);
        final List<dynamic> data = response.data as List<dynamic>;

        _bookmarks = data
            .map((json) => BookmarkModel.fromJson(json as Map<String, dynamic>))
            .toList();
        await _saveToLocal();
      } catch (e) {
        // Keep local bookmarks
      }
    }

    _setState(BookmarkState.success);
  }

  Future<void> toggleBookmark(ArticleModel article) async {
    if (isBookmarked(article.id)) {
      await removeBookmarks(article.id);
    } else {
      await addBookmark(article);
    }
  }

  Future<void> addBookmark(ArticleModel article) async {
    if (isBookmarked(article.id)) return;

    final newBookmark = BookmarkModel(
      bookmarkId: 'bm_${article.id}',
      savedAt: DateTime.now(),
      article: article,
    );

    _bookmarks = [newBookmark, ..._bookmarks];
    notifyListeners();
    await _saveToLocal();

    if (AppConstants.activeProvider == NewsApiProvider.localBackend) {
      try {
        await ApiClient.post(
          AppConstants.bookmarksEndpoint,
          data: {'articleId': article.id},
        );
      } catch (_) {}
    }
  }

  Future<void> removeBookmarks(String articleId) async {
    _bookmarks = _bookmarks.where((b) => b.article.id != articleId).toList();
    notifyListeners();
    await _saveToLocal();

    if (AppConstants.activeProvider == NewsApiProvider.localBackend) {
      try {
        await ApiClient.delete('${AppConstants.bookmarksEndpoint}/$articleId');
      } catch (_) {}
    }
  }

  bool isBookmarked(String articleId) {
    return _bookmarks.any((b) => b.article.id == articleId);
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_localBookmarksKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        _bookmarks = decoded
            .map((item) => BookmarkModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_bookmarks.map((b) => b.toJson()).toList());
      await prefs.setString(_localBookmarksKey, jsonString);
    } catch (_) {}
  }

  void _setState(BookmarkState state) {
    _state = state;
    notifyListeners();
  }
}
