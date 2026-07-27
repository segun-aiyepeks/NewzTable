class TopicModel {
  final String key;
  final String label;

  const TopicModel({required this.key, required this.label});

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      key: json['key'] as String, 
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TopicModel && other.key == key;
  }

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'TopicModel(key: $key, label: $label)';

}