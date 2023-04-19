import 'xdata_secure_rsa_platform_interface.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class XdataSecureRsa {
  static const MethodChannel _channel = MethodChannel('xdata_secure_rsa');

  static Future<String?> generateRSAKeyPair(String alias) async {
    var response = await _channel.invokeMethod('generateRSAKeyPair', {'alias': alias});
    return response;
  }

  static Future<String?> decrypt(String alias, String encryptedString) async {
    var response = await _channel.invokeMethod('decrypt', {'alias': alias, 'encryptedString': encryptedString});
    return response;
  }

  Future<String?> getPlatformVersion() {
    return XdataSecureRsaPlatform.instance.getPlatformVersion();
  }
}
