import 'package:newztable/model/article_model.dart';

class BookmarkModel {
  final String bookmarkId;
  final DateTime savedAt;
  final ArticleModel article;

  const BookmarkModel({
    required this.bookmarkId,
    required this.savedAt,
    required this.article
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      bookmarkId: json['bookmarkId'] as String,
      savedAt: DateTime.parse(json['savedAt'] as String),
      article: ArticleModel.fromJson(json['article'] as Map<String, dynamic>)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookmarkId': bookmarkId,
      'savedAt': savedAt.toIso8601String(),
      'article': article.toJson()
    };
  }

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;
    return other is BookmarkModel && other.bookmarkId == bookmarkId;
  }

  @override
  int get hashCode => bookmarkId.hashCode;

  @override
  String toString() => 'BookmarkModel(bookmarkId: $bookmarkId)';
}