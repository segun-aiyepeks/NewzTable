import 'package:flutter/material.dart';
import 'package:newztable/app.dart';
import 'package:newztable/core/utils/device_id_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DeviceIdUtil.getOrCreateDeviceId();
  runApp(const NewzTableApp());
}
