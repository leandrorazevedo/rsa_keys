import 'xdata_secure_rsa_platform_interface.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class XdataSecureRsa {
  static const MethodChannel _channel = MethodChannel('xdata_secure_rsa');

  static Future<String?> generateRSAKeyPair(String alias) async {
    var response = await _channel.invokeMethod('generateRSAKeyPair', {'alias': alias});
    return response;
  }

  static Future<String?> encrypt(String alias, String message) async {
    final String? encryptedMessage = await _channel.invokeMethod('encrypt', {
      'alias': alias,
      'message': message,
    });
    return encryptedMessage;
  }

  Future<String?> getPlatformVersion() {
    return XdataSecureRsaPlatform.instance.getPlatformVersion();
  }
}
