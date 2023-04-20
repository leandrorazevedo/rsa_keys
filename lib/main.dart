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
      'LEO8CiUUnF/litKhIB9lD2qPsmfWb/fvd9LBeq1knW/WfCbe+FksQ3i59UMydz7I8HpzB6eP+/Sf2CJ+1VaHzqyv56WMVLVQbByW/v7mzjdZyAsQgAmiQFWZiXbYewYIeKKPycPfZc53n68rHrbyMv5OaiJQAPG3P0VYgKbbRMe+PFskCNTOpgXyMcvfmSAyWM8pktHVXZb9IdFtso1s8VyrcVVRthXYxZEFMUzyBGtmdRJ1Mx3i9B8fjN8wZ7Ehtx7mGrOYQX65Uxy81YeIK/p2lm40BWFcnPtr6SIAy+zsPCuCkkDcHX2oCyH+P8pFVws5UTIzqLyeipO0v7M7NQ==';
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
