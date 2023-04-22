import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtils {
  static Future<String?> getDeviceId() async {
    String? result = "";
    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      result = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      result = androidDeviceInfo.id; // unique ID on Android
    }
    return result;
  }
}
