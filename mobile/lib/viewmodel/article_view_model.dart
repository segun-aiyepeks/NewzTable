import 'package:flutter/material.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
import 'package:newztable/model/article_model.dart';

enum ArticleState { idle, loading, success, error }

class ArticleViewModel extends ChangeNotifier {
  ArticleState _state = ArticleState.idle;
  ArticleModel? _article;
  List<ArticleModel> _relatedArticles = [];
  String _errorMessage = '';
  bool _isBookmarked = false;

  ArticleState get state => _state;
  ArticleModel? get article => _article;
  List<ArticleModel> get relatedArticles => _relatedArticles;
  String get errorMessage => _errorMessage;
  bool get isBookmarked => _isBookmarked;

  Future<void> fetchArticle(String articleId) async {
    _setState(ArticleState.loading);

    try {
      final response = await ApiClient.get(
        '/api/articles/$articleId'
      );

      final data = response.data as Map<String, dynamic>;

      _article = ArticleModel.fromJson(
        data['article'] as Map<String, dynamic>
      );

      final List<dynamic> related = data['related'] as List<dynamic>;
      _relatedArticles = related
        .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
        .toList();
      _setState(ArticleState.success);

    } catch(e) {
      _errorMessage = e.toString();
      _setState(ArticleState.error);
    }
  }

  Future<void> toggleBookmark(String articleId) async {
    final wasBookmarked = _isBookmarked;
    _isBookmarked = !_isBookmarked;
    notifyListeners();

    try {
      if(wasBookmarked) {
        await ApiClient.delete(
          '${AppConstants.bookmarksEndpoint}/$articleId'
        );
      } else {
        await ApiClient.post(
          AppConstants.bookmarksEndpoint,
          data: {'articleId': articleId }
        );
      }
    } catch(e) {
      _isBookmarked = wasBookmarked;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setBookmarkStatus(bool isBookmarked) {
    _isBookmarked = isBookmarked;
    notifyListeners();
  }

  void _setState(ArticleState state){
    _state = state;
    notifyListeners();
  }
}