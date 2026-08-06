import 'package:flutter/widgets.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SettingsState { idle, loading, success, error }

class SettingsViewModel extends ChangeNotifier {
  SettingsState _state = SettingsState.idle;
  bool _darkMode = false;
  bool _pushEnabled = false;
  String _deviceId = '';
  String _errorMessage = '';

  SettingsState get state => _state;
  bool get darkMode => _darkMode;
  bool get pushEnabled => _pushEnabled;
  String get deviceId => _deviceId;
  String get errorMessage => _errorMessage;

  Future<void> loadSettings() async {
    Future.microtask(() => _setState(SettingsState.loading));

    try {
      final prefs = await SharedPreferences.getInstance();
      _darkMode = prefs.getBool(AppConstants.darkModeKey) ?? false;
      _deviceId = prefs.getString(AppConstants.deviceIdKey) ?? '';
      _setState(SettingsState.success);
    } catch(e) {
      _errorMessage = e.toString();
      _setState(SettingsState.error);
    }
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.darkModeKey, _darkMode);

      await ApiClient.put(
        AppConstants.updatePreferencesEndpoint,
        data: {'darkMode': _darkMode}
      );
    } catch(e) {
      _darkMode = !_darkMode;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> togglePushNotification() async {
    _pushEnabled = !_pushEnabled;
    notifyListeners();

    try {
      await ApiClient.put(
        AppConstants.updatePreferencesEndpoint,
        data: {'pushEnabled': _pushEnabled}
      );
    } catch(e) {
      _pushEnabled = !_pushEnabled;
      _errorMessage = e.toString();
      _setState(SettingsState.error);
    }
  }

  Future<void> clearLocalData() async {
    _setState(SettingsState.loading);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _darkMode = false;
      _pushEnabled = false;
      _deviceId = '';
      _setState(SettingsState.success);
    } catch(e) {
      _errorMessage = e.toString();
      _setState(SettingsState.error);
    }
  }

  void _setState(SettingsState state) {
    _state = state;
    notifyListeners();
  }
}