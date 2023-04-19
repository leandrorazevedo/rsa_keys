import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:xdata_secure_rsa/xdata_secure_rsa.dart';

Future<String?> generateRSAKeyPairAndStore(String alias) async {
  try {
    final result = await XdataSecureRsa.generateRSAKeyPair(alias);
    return result;
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print('Erro ao gerar par de chaves RSA: ${e.message}');
    }
    return null;
  }
}

Future<String?> decrypt(String alias, String message) async {
  try {
    final result = await XdataSecureRsa.decrypt(alias, message);
    return result;
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print('Erro ao descriptografar: ${e.message}');
    }
    return null;
  }
}
