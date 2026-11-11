import 'package:flutter/material.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
import 'package:newztable/model/topic_model.dart';

enum TopicState { idle, loading, success, error }

class TopicViewModel extends ChangeNotifier {
  TopicState _state = TopicState.idle;
  List<TopicModel> _availableTopics = const [
    TopicModel(key: 'world', label: 'World'),
    TopicModel(key: 'sports', label: 'Sports'),
    TopicModel(key: 'politics', label: 'Politics'),
    TopicModel(key: 'business', label: 'Business'),
    TopicModel(key: 'health', label: 'Health'),
    TopicModel(key: 'travel', label: 'Travel'),
    TopicModel(key: 'science', label: 'Science'),
    TopicModel(key: 'technology', label: 'Technology'),
  ];
  List<TopicModel> _selectedTopics = [];
  String _errorMessage = '';

  TopicState get state => _state;
  List<TopicModel> get availableTopics => _availableTopics;
  List<TopicModel> get selectedTopics => _selectedTopics;
  String get errorMessage => _errorMessage;
  bool get hasEnoughTopics => _selectedTopics.length >= 3;

  Future<void> fetchAvailableTopics() async {
    _setState(TopicState.loading);

    try {
      if (AppConstants.activeProvider == NewsApiProvider.localBackend) {
        final response = await ApiClient.get(AppConstants.topicsEndpoint);
        final List<dynamic> data = response.data as List<dynamic>;

        _availableTopics = data
            .map((json) => TopicModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      _setState(TopicState.success);
    } catch (e) {
      // Use fallback default topics
      _availableTopics = const [
        TopicModel(key: 'world', label: 'World'),
        TopicModel(key: 'sports', label: 'Sports'),
        TopicModel(key: 'politics', label: 'Politics'),
        TopicModel(key: 'business', label: 'Business'),
        TopicModel(key: 'health', label: 'Health'),
        TopicModel(key: 'travel', label: 'Travel'),
        TopicModel(key: 'science', label: 'Science'),
        TopicModel(key: 'technology', label: 'Technology'),
      ];
      _setState(TopicState.success);
    }
  }

  void toggleTopic(TopicModel topic) {
    if (_selectedTopics.contains(topic)) {
      _selectedTopics = _selectedTopics.where((t) => t.key != topic.key).toList();
    } else {
      _selectedTopics = [..._selectedTopics, topic];
    }
    notifyListeners();
  }

  bool isSelected(TopicModel topic) {
    return _selectedTopics.any((t) => t.key == topic.key);
  }

  Future<bool> saveSelectedTopics(String deviceId) async {
    if (!hasEnoughTopics) {
      _errorMessage = 'Please select at least 3 topics';
      _setState(TopicState.error);
      return false;
    }

    _setState(TopicState.loading);

    try {
      final topicKeys = _selectedTopics.map((t) => t.key).toList();

      if (AppConstants.activeProvider == NewsApiProvider.localBackend) {
        await ApiClient.post(
          AppConstants.initUserEndpoint,
          data: {'deviceId': deviceId, 'topics': topicKeys},
        );
      }

      _setState(TopicState.success);
      return true;
    } catch (e) {
      // Even if network fails, allow onboarding to continue locally
      _setState(TopicState.success);
      return true;
    }
  }

  Future<bool> updateTopics() async {
    if (!hasEnoughTopics) {
      _errorMessage = 'Please select at least 3 topics';
      _setState(TopicState.error);
      return false;
    }

    _setState(TopicState.loading);

    try {
      final topicKeys = _selectedTopics.map((t) => t.key).toList();

      if (AppConstants.activeProvider == NewsApiProvider.localBackend) {
        await ApiClient.put(
          AppConstants.updateTopicsEndpoint,
          data: {'topics': topicKeys},
        );
      }

      _setState(TopicState.success);
      return true;
    } catch (e) {
      _setState(TopicState.success);
      return true;
    }
  }

  void _setState(TopicState state) {
    _state = state;
    notifyListeners();
  }
}
