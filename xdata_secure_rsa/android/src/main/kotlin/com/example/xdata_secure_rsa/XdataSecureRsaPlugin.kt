package com.example.xdata_secure_rsa

import androidx.annotation.NonNull

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.KeyProtection

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import java.security.*;
import java.security.spec.*;
import java.security.interfaces.*
import java.math.BigInteger
import javax.crypto.Cipher
import java.security.KeyFactory
import java.util.Base64

/** XdataSecureRsaPlugin */
class XdataSecureRsaPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "xdata_secure_rsa")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "generateRSAKeyPair" -> {
                try {
                    val alias = call.argument<String>("alias")
                    val publicKey = generateRSAKeyPair(alias!!)
                    result.success(publicKey)
                } catch (e: Exception) {
                    result.error("KEY_GENERATION_FAILED", e.message, null)
                }
            }
            "decrypt" -> {
                try {
                    val alias = call.argument<String>("alias")
                    val encryptedString = call.argument<String>("encryptedString")
                    val response = decrypt(alias!!, encryptedString!!)
                    result.success(response)
                } catch (e: Exception) {
                    result.error("DECRYPT_FAILED", e.message, null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun generateRSAKeyPair(alias: String): String? {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)

        val ksAlias = keyStore.getCertificate(alias)
        if (ksAlias != null) {
            val publicKey = ksAlias.publicKey
            if (publicKey != null)
                return Base64.getEncoder().encodeToString(publicKey.encoded)
//                return Base64.encodeToString(publicKey.encoded, Base64.DEFAULT)
        }

        val keyPairGenerator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA, "AndroidKeyStore")
        val keyGenParameterSpec = KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
            .setKeySize(2048)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_PKCS1)
            .setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512)
            .build()
        keyPairGenerator.initialize(keyGenParameterSpec)
        var pubKey = keyPairGenerator.generateKeyPair().public
        return Base64.getEncoder().encodeToString(pubKey.encoded)
//        return Base64.encodeToString(pubKey.encoded, Base64.DEFAULT)
    }

    private fun decrypt(alias: String, encryptedString: String): String {
        // Carregando a chave privada da KeyStore
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)

        val privateKeyEntry = keyStore.getEntry(alias, null) as KeyStore.PrivateKeyEntry
        val privateKey = privateKeyEntry.privateKey

        val cipher = Cipher.getInstance("RSA/NONE/PKCS1Padding")
        cipher.init(Cipher.DECRYPT_MODE, privateKey)

//        val encryptedBytes = Base64.decode(encryptedString, Base64.DEFAULT)
        val encryptedBytes = Base64.getDecoder().decode(encryptedString)
        val decryptedBytes = cipher.doFinal(encryptedBytes)

        return String(decryptedBytes, charset("UTF-8"))
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

