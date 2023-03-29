import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/asn1/asn1_object.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_object_identifier.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import "package:pointycastle/api.dart";

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair({int bitLength = 2048}) {
  final keyGen = RSAKeyGenerator();
  final secureRandom = getSecureRandom();

  keyGen.init(ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64), secureRandom));

  final pair = keyGen.generateKeyPair();

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

SecureRandom getSecureRandom() {
  final secureRandom = FortunaRandom();

  secureRandom.seed(KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));

  return secureRandom;
}

String encodeRSAPublicKeyToPem(RSAPublicKey publicKey) {
  const BEGIN_PUBLIC_KEY = '-----BEGIN PUBLIC KEY-----';
  const END_PUBLIC_KEY = '-----END PUBLIC KEY-----';

  var algorithmSeq = ASN1Sequence();
  var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(ASN1ObjectIdentifier.fromName('rsaEncryption'));
  algorithmSeq.add(paramsAsn1Obj);

  var publicKeySeq = ASN1Sequence();
  publicKeySeq.add(ASN1Integer(publicKey.modulus));
  publicKeySeq.add(ASN1Integer(publicKey.exponent));
  var publicKeySeqBitString = ASN1BitString(stringValues: Uint8List.fromList(publicKeySeq.encode()));

  var topLevelSeq = ASN1Sequence();
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqBitString);
  var dataBase64 = base64.encode(topLevelSeq.encode());
  var chunks = chunk(dataBase64, 64);

  return '$BEGIN_PUBLIC_KEY\n${chunks.join('\n')}\n$END_PUBLIC_KEY';
}

List<String> chunk(String s, int chunkSize) {
  var chunked = <String>[];
  for (var i = 0; i < s.length; i += chunkSize) {
    var end = (i + chunkSize < s.length) ? i + chunkSize : s.length;
    chunked.add(s.substring(i, end));
  }
  return chunked;
}

String rsaEncrypt(String value, RSAPublicKey publicKey) {
  var cipher = RSAEngine()..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
  var cipherText = cipher.process(Uint8List.fromList(value.codeUnits));
  return String.fromCharCodes(cipherText);
}

String rsaDecrypt(String cipherMessage, RSAPrivateKey privateKey) {
  var cipher = RSAEngine()..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  var decrypted = cipher.process(Uint8List.fromList(cipherMessage.codeUnits));

  return String.fromCharCodes(decrypted);
}
