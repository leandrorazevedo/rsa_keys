package com.example.xdata_secure_rsa

import androidx.annotation.NonNull

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.KeyProtection
import android.util.Base64

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.interfaces.RSAPublicKey
import java.security.spec.RSAKeyGenParameterSpec
import javax.crypto.Cipher


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
                    val keyPair = generateRSAKeyPair(alias!!)
                    val publicKey = keyPair.public
                    val publicKeyString = Base64.encodeToString(publicKey.encoded, Base64.DEFAULT)
                    val resultMap = hashMapOf<String, Any>("publicKey" to publicKeyString)
                    result.success(resultMap)
                } catch (e: Exception) {
                    result.error("KEY_GENERATION_FAILED", e.message, null)
                }
            }
            "encrypt" -> {
                val alias = call.argument<String>("alias")
                val message = call.argument<String>("message")
                try {
                    val encryptedMessage = encrypt(alias!!, message!!)
                    result.success(encryptedMessage)
                } catch (e: Exception) {
                    result.error("ENCRYPTION_FAILED", e.message, null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun generateRSAKeyPair(alias: String): java.security.KeyPair {
        val keyPairGenerator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_RSA, "AndroidKeyStore")
        val keyGenParameterSpec = KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
            .setKeySize(2048)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_RSA_PKCS1)
            .setDigests(KeyProperties.DIGEST_SHA256, KeyProperties.DIGEST_SHA512)
            .build()
        keyPairGenerator.initialize(keyGenParameterSpec)
        val keyPair = keyPairGenerator.generateKeyPair()
        return keyPair
    }

    private fun encrypt(alias: String, message: String): String {
        val keyStore = KeyStore.getInstance("AndroidKeyStore")
        keyStore.load(null)
        val privateKeyEntry = keyStore.getEntry(alias, null) as KeyStore.PrivateKeyEntry
        val publicKey = privateKeyEntry.certificate.publicKey

        val inputBytes = message.toByteArray(Charsets.UTF_8)
        val cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding")
        cipher.init(Cipher.ENCRYPT_MODE, publicKey)
        val encryptedBytes = cipher.doFinal(inputBytes)

        return Base64.encodeToString(encryptedBytes, Base64.DEFAULT)
    }


    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}

