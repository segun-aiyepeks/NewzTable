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
    required this.publishedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: (json['_id'] ?? json['id'] ?? json['url'] ?? UniqueKeyGenerator.next()).toString(),
      topic: json['topic'] as String? ?? 'General',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      url: json['url'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      sourceName: json['sourceName'] as String? ?? 'NewzTable',
      language: json['language'] as String? ?? 'en',
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Factory constructor for RSS-to-JSON payloads (BBC, CNN, etc.)
  factory ArticleModel.fromRssJson(Map<String, dynamic> item, {String defaultTopic = 'General'}) {
    // Extract thumbnail from enclosure or thumbnail or description
    String? imgUrl = item['thumbnail'] as String?;
    if (imgUrl == null || imgUrl.isEmpty) {
      if (item['enclosure'] is Map && item['enclosure']['thumbnail'] != null) {
        imgUrl = item['enclosure']['thumbnail'] as String?;
      } else if (item['enclosure'] is Map && item['enclosure']['link'] != null) {
        imgUrl = item['enclosure']['link'] as String?;
      }
    }

    // Determine clean topic
    String topic = defaultTopic;
    if (item['categories'] is List && (item['categories'] as List).isNotEmpty) {
      topic = (item['categories'] as List).first.toString();
    }

    final pubDateStr = item['pubDate'] as String?;
    DateTime pubDate = DateTime.now();
    if (pubDateStr != null) {
      pubDate = DateTime.tryParse(pubDateStr) ?? DateTime.now();
    }

    final link = item['link'] as String? ?? item['guid'] as String? ?? '';
    final id = item['guid'] as String? ?? link;

    return ArticleModel(
      id: id.isNotEmpty ? id : UniqueKeyGenerator.next(),
      topic: topic,
      title: _stripHtml(item['title'] as String? ?? 'Untitled'),
      description: _stripHtml(item['description'] as String? ?? ''),
      content: _stripHtml(item['content'] as String? ?? item['description'] as String? ?? ''),
      url: link,
      imageUrl: (imgUrl != null && imgUrl.isNotEmpty) ? imgUrl : null,
      sourceName: item['author'] != null && (item['author'] as String).isNotEmpty
          ? item['author'] as String
          : 'BBC News',
      language: 'en',
      publishedAt: pubDate,
    );
  }

  // Factory constructor for The Guardian API
  factory ArticleModel.fromGuardian(Map<String, dynamic> item) {
    final fields = item['fields'] as Map<String, dynamic>? ?? {};
    final id = item['id'] as String? ?? UniqueKeyGenerator.next();
    final sectionName = item['sectionName'] as String? ?? 'World';
    final webTitle = item['webTitle'] as String? ?? '';
    final webUrl = item['webUrl'] as String? ?? '';
    final webPublicationDate = item['webPublicationDate'] as String?;
    final thumbnail = fields['thumbnail'] as String?;
    final trailText = fields['trailText'] as String? ?? '';
    final byline = fields['byline'] as String? ?? 'The Guardian';

    return ArticleModel(
      id: id,
      topic: sectionName,
      title: _stripHtml(webTitle),
      description: _stripHtml(trailText),
      content: _stripHtml(trailText),
      url: webUrl,
      imageUrl: thumbnail,
      sourceName: byline,
      language: 'en',
      publishedAt: webPublicationDate != null
          ? DateTime.tryParse(webPublicationDate) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Factory constructor for NewsAPI.org
  factory ArticleModel.fromNewsApi(Map<String, dynamic> item, {String defaultTopic = 'General'}) {
    final source = item['source'] as Map<String, dynamic>? ?? {};
    final sourceName = source['name'] as String? ?? 'News';
    final url = item['url'] as String? ?? '';

    return ArticleModel(
      id: url.isNotEmpty ? url : UniqueKeyGenerator.next(),
      topic: defaultTopic,
      title: item['title'] as String? ?? 'Untitled',
      description: item['description'] as String? ?? '',
      content: item['content'] as String? ?? item['description'] as String? ?? '',
      url: url,
      imageUrl: item['urlToImage'] as String?,
      sourceName: sourceName,
      language: 'en',
      publishedAt: item['publishedAt'] != null
          ? DateTime.tryParse(item['publishedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static String _stripHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
    if (identical(this, other)) return true;
    return other is ArticleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ArticleModel(id: $id, title: $title)';
}

class UniqueKeyGenerator {
  static int _count = 0;
  static String next() => 'art_${DateTime.now().millisecondsSinceEpoch}_${_count++}';
}
