import Flutter
import UIKit
import Security

public class SwiftNomeDoSeuPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nome_do_seu_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftNomeDoSeuPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "generateRSAKeyPair" {
      guard let args = call.arguments as
      guard let args = call.arguments as? [String: Any],
            let alias = args["alias"] as? String else {
        result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        return
      }

      do {
        let publicKey = try generateRSAKeyPairAndStore(alias: alias)
        let resultMap: [String: Any] = ["publicKey": publicKey]
        result(resultMap)
      } catch {
        result(FlutterError(code: "KEY_GENERATION_FAILED", message: error.localizedDescription, details: nil))
      }
    } else if call.method == "encrypt" {
         guard let args = call.arguments as? [String: Any],
               let alias = args["alias"] as? String,
               let message = args["message"] as? String else {
             result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
             return
         }

         do {
             let encryptedMessage = try encrypt(alias: alias, message: message)
             result(encryptedMessage)
         } catch {
             result(FlutterError(code: "ENCRYPTION_FAILED", message: error.localizedDescription, details: nil))
         }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  private func generateRSAKeyPairAndStore(alias: String) throws -> String {
    let publicKeyAttr = [
      kSecAttrIsPermanent: true,
      kSecAttrApplicationTag: alias + ".public",
      kSecReturnData: true
    ] as CFDictionary

    let privateKeyAttr = [
      kSecAttrIsPermanent: true,
      kSecAttrApplicationTag: alias + ".private",
    ] as CFDictionary

    let keyPairAttr = [
      kSecAttrKeyType: kSecAttrKeyTypeRSA,
      kSecAttrKeySizeInBits: 2048,
      kSecPublicKeyAttrs: publicKeyAttr,
      kSecPrivateKeyAttrs: privateKeyAttr
    ] as CFDictionary

    var publicKey: SecKey?
    var privateKey: SecKey?

    let status = SecKeyGeneratePair(keyPairAttr, &publicKey, &privateKey)

    guard status == errSecSuccess else {
      throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    }

    var error: Unmanaged<CFError>?
    guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey!, &error) as Data? else {
      throw error!.takeRetainedValue() as Error
    }

    return publicKeyData.base64EncodedString()
  }

  private func encrypt(alias: String, message: String) throws -> String {
      let publicKey = try getPublicKey(alias: alias)

      let messageData = message.data(using: .utf8)!
      var encryptedData = Data(count: SecKeyGetBlockSize(publicKey))

      var encryptedDataLength = encryptedData.count
      let status = encryptedData.withUnsafeMutableBytes { encryptedBytes -> OSStatus in
          messageData.withUnsafeBytes { messageBytes -> OSStatus in
              SecKeyEncrypt(publicKey, .PKCS1, messageBytes, messageData.count, encryptedBytes, &encryptedDataLength)
          }
      }

      guard status == errSecSuccess else {
          throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
      }

      return encryptedData.base64EncodedString()
  }
}
