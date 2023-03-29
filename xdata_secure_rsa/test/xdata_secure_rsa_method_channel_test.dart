import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xdata_secure_rsa/xdata_secure_rsa_method_channel.dart';

void main() {
  MethodChannelXdataSecureRsa platform = MethodChannelXdataSecureRsa();
  const MethodChannel channel = MethodChannel('xdata_secure_rsa');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
