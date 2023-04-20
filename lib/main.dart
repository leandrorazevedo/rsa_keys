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
      'WHnhwwgoLbcdKIFlQ1eyFUcWpoYuuBXoBBfPueiAsrbgRD21wj+6W/DkfoFD7CTKJFisAxGPvh2IHljXllSmDsH2kT71BGNb3/fIt01GE5F/lGK24gifU4rxY5uvqTtA7y//+ORBuFoxKe722NCtfZxHi2SXcCwYZGGE5FX3cEy4fjQDLCkHhy3tp/xJZobe3d1+j/yAFW6mc2KuUExan3DFr+qdIlGjNNepgk1ZmH0mEl6us2Ph3IT/Yajv1SRnSKWc9UEprcaVaIcme97bdAfGYiPGyvydB3RwUoGr3W3fnnidrFh1IBmbgr80z2HM60Fmq7S0pjg48PJJGbYBTw==';
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
