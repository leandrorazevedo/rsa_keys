import Flutter
import UIKit
import Foundation
import Security



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
    
    //    private func generateRSAKeyPairAndStore(alias: String) throws -> String {
    //        let publicKeyAttr = [
    //          kSecAttrIsPermanent: true,
    //          kSecAttrApplicationTag: alias + ".public",
    //          kSecReturnData: true
    //        ] as CFDictionary
    //
    //        let privateKeyAttr = [
    //          kSecAttrIsPermanent: true,
    //          kSecAttrApplicationTag: alias + ".private",
    //        ] as CFDictionary
    //
    //        let keyPairAttr = [
    //          kSecAttrKeyType: kSecAttrKeyTypeRSA,
    //          kSecAttrKeySizeInBits: 2048,
    //          kSecPublicKeyAttrs: publicKeyAttr,
    //          kSecPrivateKeyAttrs: privateKeyAttr
    //        ] as CFDictionary
    //
    //        var publicKey: SecKey?
    //        var privateKey: SecKey?
    //
    //        let status = SecKeyGeneratePair(keyPairAttr, &publicKey, &privateKey)
    //
    //        guard status == errSecSuccess else {
    //          throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
    //        }
    //
    //        var error: Unmanaged<CFError>?
    //        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey!, &error) as Data? else {
    //          throw error!.takeRetainedValue() as Error
    //        }
    //
    //        return publicKeyData.base64EncodedString()
    //      }
    
    
    private func generateRSAKeyPairAndStore(alias: String) -> String? {
        let tag = alias.data(using: .utf8)!
        
        // Verifica se o par de chaves já existe
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
        
        if status == errSecSuccess {
            return publicKeyToBase64(publicKey: (item as! SecKey)) // Retorna a chave pública existente em base64
        }
        
        // Cria um novo par de chaves RSA
        let keyPairAttributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag
            ],
            kSecPublicKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: tag
            ]
        ]
        
        var publicKey, privateKey: SecKey?
        let generateStatus = SecKeyGeneratePair(keyPairAttributes as CFDictionary, &publicKey, &privateKey)
        
        guard generateStatus == errSecSuccess else {
            print("Erro ao gerar o par de chaves RSA: \(generateStatus)")
            return nil
        }
        
        return publicKeyToBase64(publicKey: publicKey!)
    }
    
    
    private func encrypt(alias: String, message: String) -> String? {
        let tag = alias.data(using: .utf8)!
        
        // Busca a chave privada
        let getQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecReturnRef as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            return "Erro ao obter a chave privada: \(status)"
        }
        
        let privateKey = item as! SecKey
        
        // Criptografa a mensagem com a chave privada
        let messageData = message.data(using: .utf8)!
        let algorithm = SecKeyAlgorithm.rsaEncryptionOAEPSHA1
        
        guard SecKeyIsAlgorithmSupported(privateKey, .encrypt, algorithm) else {
            return "Algoritmo não suportado pela chave privada"
        }
        
        var error: Unmanaged<CFError>?
        guard let encryptedData = SecKeyCreateEncryptedData(privateKey, algorithm, messageData as CFData, &error) else {
            return "Erro ao criptografar a mensagem com a chave privada: \(error.debugDescription)"
        }
        
        return (encryptedData as Data).base64EncodedString()
    }
    
    
    private  func publicKeyToBase64(publicKey: SecKey) -> String? {
        var error: Unmanaged<CFError>?
        if let cfData = SecKeyCopyExternalRepresentation(publicKey, &error) {
            let data = cfData as Data
            return data.base64EncodedString()
        }
        
        print("Erro ao converter a chave pública para base64: \(error.debugDescription)")
        return nil
    }
    
    
}


