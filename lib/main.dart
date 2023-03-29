import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa/RSAUtil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String pubKeyAsPem = "";
  String valueEncrypted = "";
  String valueDecrypted = "";
  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> rsaKeyPair;
  TextEditingController textController = TextEditingController(text: '5573 2165 5983 0359');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                rsaKeyPair = generateRSAKeyPair();
                var publicKey = rsaKeyPair.publicKey;
                setState(() {
                  pubKeyAsPem = encodeRSAPublicKeyToPem(publicKey);
                });
              },
              child: const Text('Gerar Chaves RSA'),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: textController,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      valueEncrypted = rsaEncrypt(textController.text, rsaKeyPair.publicKey);
                    });
                  },
                  child: const Text('Encrypt'),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      valueDecrypted = rsaDecrypt(valueEncrypted, rsaKeyPair.privateKey);
                    });
                  },
                  child: const Text('Decrypt'),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(pubKeyAsPem),
            const SizedBox(
              height: 20,
            ),
            Text(valueEncrypted),
            SizedBox(
              height: 10,
            ),
            Text(valueDecrypted),
          ],
        ),
      ),
    );
  }
}
