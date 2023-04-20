import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

class SecurityHelper {

  static Uint8List _createUint8ListFromString(String input) {
    final data = Uint8List(input.length);
    for (int i = 0; i < input.length; i++) {
      data[i] = input.codeUnitAt(i);
    }
    return data;
  }

  static Encrypted encryptWithAES(String key, String plainText) {
    final cipherKey = Key.fromBase64(key);
    final encryptService = Encrypter(AES(cipherKey, mode: AESMode.cbc));
    final initVector = IV.fromUtf8(key.substring(0, 16));

    Encrypted encryptedData = encryptService.encrypt(plainText, iv: initVector);
    return encryptedData;
  }

}