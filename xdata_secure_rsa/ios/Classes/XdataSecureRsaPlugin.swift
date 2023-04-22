import Flutter
import UIKit
import CoreFoundation
import Foundation
import Security
import CommonCrypto


public class XdataSecureRsaPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "xdata_secure_rsa", binaryMessenger: registrar.messenger())
        let instance = XdataSecureRsaPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "generateRSAKeyPair" {
            guard let args = call.arguments as? [String: Any],
                  let alias = args["alias"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            
            do {
                let publicKey = try generateRSAKeyPairAndStore(alias: alias)
                result(publicKey)
            } catch {
                result(FlutterError(code: "KEY_GENERATION_FAILED", message: error.localizedDescription, details: nil))
            }
        } else if call.method == "decrypt" {
            guard let args = call.arguments as? [String: Any],
                  let alias = args["alias"] as? String,
                  let encryptedString = args["encryptedString"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            
            do {
                let decryptedMessage = try decrypt(alias: alias, encryptedString: encryptedString)
                result(decryptedMessage)
            } catch {
                result(FlutterError(code: "ENCRYPTION_FAILED", message: error.localizedDescription, details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func generateRSAKeyPairAndStore(alias: String) -> String? {

        if let existingPublicKey = getPublicKey(tag: alias) {
            return existingPublicKey
        }

        let publicKeyTag = alias + ".public"
        let privateKeyTag = alias + ".private"

        let publicKeyParameters: [NSString: Any] = [
            kSecAttrIsPermanent: true,
            kSecAttrApplicationTag: publicKeyTag.data(using: .utf8)!,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecClass: kSecClassKey,
            kSecReturnData: kCFBooleanTrue
        ]


        let privateKeyParameters: [NSString: Any] = [
            kSecAttrIsPermanent: true,
            kSecAttrApplicationTag: privateKeyTag.data(using: .utf8)!,
            kSecAttrCanDecrypt: kCFBooleanTrue
        ]

        let parameters: [NSString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits: 2048,
            kSecPublicKeyAttrs: publicKeyParameters,
            kSecPrivateKeyAttrs: privateKeyParameters
        ]

        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateRandomKey(parameters as CFDictionary, &error) else {
            return nil
        }

        let publicKey = SecKeyCopyPublicKey(secKey)

        let privateKeyData = SecKeyCopyExternalRepresentation(publicKey!, nil)

        let x509Data = publicKeyDataX509(publicKey: privateKeyData  as! SecKey)
        return x509Data!.base64EncodedString()
    }

    private func decrypt(alias: String, encryptedString: String) throws -> String? {

        let privateKeyRef = getPrivateKey(tag: alias) as! SecKey
        let blockSize = SecKeyGetBlockSize(privateKeyRef)
        var error: Unmanaged<CFError>?

        guard let messageData = Data(base64Encoded: encryptedString) else {
            return("Bad message to decrypt")
        }

        if let decryptedCFData = SecKeyCreateDecryptedData(privateKeyRef, .rsaEncryptionOAEPSHA1, messageData as CFData, &error) {
            let decryptedData = decryptedCFData as Data
            let base64String = decryptedData.base64EncodedString()
            return base64String
        }

        return("Erro ao decriptografar dados: \(error.debugDescription)")
    }

    private func getPublicKey(tag: String) -> String? {
        let publicKeyTag = tag + ".public"

        let query: [NSString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag: publicKeyTag.data(using: .utf8)!,
            kSecReturnRef: true
        ]

        var keyRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &keyRef)

        if status == errSecSuccess {
            let x509Data = publicKeyDataX509(publicKey: keyRef as! SecKey)
            return x509Data!.base64EncodedString()
        }

        return nil
    }

    private func getPrivateKey(tag: String) -> SecKey? {
        let publicKeyTag = tag + ".private"

        let query: [NSString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag: publicKeyTag.data(using: .utf8)!,
            kSecReturnRef: true
        ]

        var keyRef: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &keyRef)

        if status == errSecSuccess {
            return keyRef as! SecKey
        }

        return nil
    }

    private func publicKeyDataX509(publicKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            print("Error exporting public key: \(error.debugDescription)")
            return nil
        }

        let x509Header: [UInt8] = [
            0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
        ]

        var keyData = Data(x509Header)
        keyData.append(publicKeyData)
        return keyData
    }

}


