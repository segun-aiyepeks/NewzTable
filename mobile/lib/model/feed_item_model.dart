import 'package:newztable/model/article_model.dart';

enum FeedItemType { article, ad}

class FeedItemModel {
  final FeedItemType type;
  final ArticleModel? article;
  final String? slotId;

  const FeedItemModel._({
    required this.type,
    this.article,
    this.slotId,
  });

  factory FeedItemModel.article(ArticleModel article) {
    return FeedItemModel._(
      type: FeedItemType.article,
      article: article
    );
  }

  factory FeedItemModel.ad(String slotId) {
    return FeedItemModel._(
      type: FeedItemType.ad,
      slotId: slotId
    );
  }

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    if(type == 'ad') {
      return FeedItemModel.ad(json['slotId'] as String);
    }

    return FeedItemModel.article(
      ArticleModel.fromJson(json['data'] as Map<String, dynamic>)
    );
  }

  bool get isArticle => type == FeedItemType.article;
  bool get isAd => type == FeedItemType.ad;
}