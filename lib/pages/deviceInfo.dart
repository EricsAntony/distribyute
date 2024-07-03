import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceInfo {
  //Method
  // Function to fetch the device serial number
  Future<String> fetchDeviceSerialNumber(context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.fingerprint;
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    } else {
      return 'Unknown Device';
    }
  }
}


