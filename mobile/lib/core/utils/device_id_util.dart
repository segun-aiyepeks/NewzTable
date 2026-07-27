import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdUtil {
  DeviceIdUtil._();

  static const _uuid = Uuid();

  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(AppConstants.deviceIdKey);

    if(deviceId == null) {
      deviceId = _uuid.v4();
      await prefs.setString(AppConstants.deviceIdKey, deviceId);
    }

    ApiClient.setDeviceId(deviceId);
    return deviceId;
  }
}