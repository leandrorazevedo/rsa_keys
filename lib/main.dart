import 'package:flutter/material.dart';
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
  static const String alias = 'SuperApp_RSA';
  static const String sessionKey =
      'dsQoYZesvTrhibGTovxv2I0ekkgIBXf34W53yrg1H/c1JHqVGcuS3vto+l+U5eZ5VJaFHDgomXhkJmNFVzwNdnzF1bB2me9S7mNz9Jx/BvZ6MF3zNV0fWFEKb9cSxIfm8rIugyYZkv4Oa5CVpPRSkx/gOPGG7hV3JdlomH582KNbouO1QVhS0iV8gNIxObZkEPxMxoj+AWJeoQcSgYbSCkPYsfO3MUdNpflnr946z+UCQnNC4MSPIhb0DrBgM3FL4o1A7UIPcjKZeXmoeAbVJH+PqMcetAO7uxwXphcezAjdnFJausS+2KPZJML4+oFRBvwk6wm1Q1unLFxa0RhYRw==';
  String pubKey = "";
  String pubKeyAsPem = "";
  String valueEncrypted = "";
  String valueDecrypted = "";
  String sessionKeyDecrypted = "";

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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    pubKey = await generateRSAKeyPairAndStore(alias) ?? "";
                    setState(() {});
                  },
                  child: const Text('Gerar Chaves RSA'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () async {
                    sessionKeyDecrypted = await decrypt(alias, sessionKey) ?? "";
                    setState(() {});
                  },
                  child: const Text('Decrypt Session Key'),
                ),
              ],
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
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // valueDecrypted = rsaDecrypt(valueEncrypted, rsaKeyPair.privateKey);
                    });
                  },
                  child: const Text('Decrypt'),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SelectableText(pubKey),
            const SizedBox(
              height: 20,
            ),
            SelectableText(sessionKeyDecrypted),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
