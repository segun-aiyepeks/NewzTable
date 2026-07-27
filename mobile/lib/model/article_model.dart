class ArticleModel {
  final String id;
  final String topic;
  final String title;
  final String description;
  final String content;
  final String url;
  final String? imageUrl;
  final String sourceName;
  final String language;
  final DateTime publishedAt;

  const ArticleModel({
    required this.id,
    required this.topic,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.imageUrl,
    required this.sourceName,
    required this.language,
    required this.publishedAt
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['_id'] as String, 
      topic: json['topic'] as String, 
      title: json['title'] as String, 
      description: json['description'] as String? ?? '', 
      content: json['content'] as String? ?? '', 
      url: json['url'] as String, 
      imageUrl: json['imageUrl'] as String?, 
      sourceName: json['sourceName'] as String? ?? 'Unknown', 
      language: json['language'] as String? ?? 'en', 
      publishedAt: DateTime.parse(json['publishedAt'] as String));
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'topic': topic,
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'sourceName': sourceName,
      'language': language,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if(identical(this, other)) return true;
    return other is ArticleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ArticleModel(id: $id, title: $title)';

}