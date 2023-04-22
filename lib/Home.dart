import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rsa/LoginResultDto.dart';
import 'package:velocity_x/velocity_x.dart';

import 'RSAUtil.dart';
import 'SecurityHelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String alias = 'SuperApp_RSA';
  var sessionKey = "";
  var valueEncrypted = "";
  var accessToken = "";

  @override
  Widget build(BuildContext context) {
    TextEditingController valueToEncryptController = TextEditingController();
    final box = GetStorage();
    LoginResult session = box.read('session');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: "Utilitários".text.make(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    sessionKey = await decrypt(alias, session.sessionKey ?? "") ?? "";
                    setState(() {});
                  },
                  child: const Text('Get Session Key'),
                ),
                16.widthBox,
                ElevatedButton(
                  onPressed: () async {
                    accessToken = session.accessToken ?? "";
                    setState(() {});
                  },
                  child: const Text('Show Access Token'),
                ),
              ],
            ),
            SelectableText(sessionKey),
            16.heightBox,
            SelectableText(accessToken),
            16.heightBox,
            Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    label: "Digite um valor para criptografar com a session key".text.make(),
                  ),
                  controller: valueToEncryptController,
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (sessionKey == "") {
                      valueEncrypted = "Session Key não definida";
                      return;
                    }

                    if (valueToEncryptController.text != "") {
                      final response = SecurityHelper.encryptWithAES(sessionKey, valueToEncryptController.text);
                      valueEncrypted = response.base64;
                      setState(() {});
                    }
                  },
                  child: const Text('Encrypt with session key'),
                ),
              ],
            ),
            SelectableText(valueEncrypted),
            16.heightBox,
          ],
        ),
      ),
    );
  }
}
