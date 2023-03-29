import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'xdata_secure_rsa_platform_interface.dart';

/// An implementation of [XdataSecureRsaPlatform] that uses method channels.
class MethodChannelXdataSecureRsa extends XdataSecureRsaPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xdata_secure_rsa');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
