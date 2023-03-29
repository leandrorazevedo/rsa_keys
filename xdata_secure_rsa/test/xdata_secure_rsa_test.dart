import 'package:flutter_test/flutter_test.dart';
import 'package:xdata_secure_rsa/xdata_secure_rsa.dart';
import 'package:xdata_secure_rsa/xdata_secure_rsa_platform_interface.dart';
import 'package:xdata_secure_rsa/xdata_secure_rsa_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockXdataSecureRsaPlatform
    with MockPlatformInterfaceMixin
    implements XdataSecureRsaPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final XdataSecureRsaPlatform initialPlatform = XdataSecureRsaPlatform.instance;

  test('$MethodChannelXdataSecureRsa is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelXdataSecureRsa>());
  });

  test('getPlatformVersion', () async {
    XdataSecureRsa xdataSecureRsaPlugin = XdataSecureRsa();
    MockXdataSecureRsaPlatform fakePlatform = MockXdataSecureRsaPlatform();
    XdataSecureRsaPlatform.instance = fakePlatform;

    expect(await xdataSecureRsaPlugin.getPlatformVersion(), '42');
  });
}
