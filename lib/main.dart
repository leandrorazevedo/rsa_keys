import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rsa/Home.dart';
import 'package:rsa/LoginResultDto.dart';
import 'package:velocity_x/velocity_x.dart';

import 'DeviceInfo.dart';
import 'DeviceInfoUtils.dart';
import 'RSAUtil.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController emailController = TextEditingController(text: 'leandrorazevedo@gmail.com');
  TextEditingController passwordController = TextEditingController(text: '123456');

  static const String alias = 'SuperApp_RSA';
  var publicKey = "";
  var deviceId = "";
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    debugPrint("Init State");
    Future.delayed(Duration.zero, () async {
      deviceId = await DeviceInfoUtils.getDeviceId() ?? "";
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                label: "e-mail".text.make(),
              ),
            ),
            16.heightBox,
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                label: "password".text.make(),
              ),
            ),
            16.heightBox,
            Row(
              children: [
                Text("Device ID : $deviceId"),
              ],
            ),
            16.heightBox,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: login,
                  child: "Login".text.make(),
                ),
                16.widthBox,
                ElevatedButton(
                  onPressed: () async {
                    publicKey = await generateRSAKeyPairAndStore(alias) ?? "";
                    box.write('publicKey', publicKey);
                    setState(() {});
                  },
                  child: const Text('Gerar Chaves RSA'),
                ),
                16.widthBox,
                ElevatedButton(
                  onPressed: () {
                    Get.to(const DeviceInfoScreen());
                  },
                  child: const Text('Device Info'),
                ),
              ],
            ),
            SelectableText(publicKey),
            16.heightBox,
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    final dio = Dio();
    var response = await dio.post('https://949f-177-30-89-181.ngrok-free.app/auth/login', data: {
      'email': emailController.text,
      'password': passwordController.text,
      'deviceId': deviceId,
    });
    if (response.statusCode == 200) {
      var login = LoginResult.fromJson(response.data);
      final box = GetStorage();
      box.write('session', login);

      Get.to(const HomeScreen());
    }
  }
}
