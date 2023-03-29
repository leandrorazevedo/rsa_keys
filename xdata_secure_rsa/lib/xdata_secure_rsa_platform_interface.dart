import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'xdata_secure_rsa_method_channel.dart';

abstract class XdataSecureRsaPlatform extends PlatformInterface {
  /// Constructs a XdataSecureRsaPlatform.
  XdataSecureRsaPlatform() : super(token: _token);

  static final Object _token = Object();

  static XdataSecureRsaPlatform _instance = MethodChannelXdataSecureRsa();

  /// The default instance of [XdataSecureRsaPlatform] to use.
  ///
  /// Defaults to [MethodChannelXdataSecureRsa].
  static XdataSecureRsaPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XdataSecureRsaPlatform] when
  /// they register themselves.
  static set instance(XdataSecureRsaPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
