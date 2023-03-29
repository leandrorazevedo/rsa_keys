import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:xdata_secure_rsa/xdata_secure_rsa.dart';

Future<String?> generateRSAKeyPairAndStore(String alias) async {
  try {
    final resultMap = await XdataSecureRsa.generateRSAKeyPair(alias);
    return resultMap['publicKey'];
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print('Erro ao gerar par de chaves RSA: ${e.message}');
    }
    return null;
  }
}

Future<String?> encrypt(String alias, String message) async {
  try {
    final result = await XdataSecureRsa.encrypt(alias, message);
    return result;
  } on PlatformException catch (e) {
    if (kDebugMode) {
      print('Erro ao criptografar a string: ${e.message}');
    }
    return null;
  }
}
