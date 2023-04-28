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

  final box = GetStorage();
  var url = box.read('url_api');
  if (url == '') {
    box.write('url_api', 'https://dev.xdatasolucoes.com.br:9091');
  }

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
  final box = GetStorage();

  TextEditingController emailController = TextEditingController(text: 'leandrorazevedo@gmail.com');
  TextEditingController passwordController = TextEditingController(text: '123456');
  TextEditingController urlApiController = TextEditingController();

  static const String alias = 'SuperApp_RSA';
  var publicKey = "";
  var deviceId = "";

  @override
  void initState() {
    super.initState();
    urlApiController.text = box.read('url_api');
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
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            VStack([
              TextField(
                controller: urlApiController,
                decoration: InputDecoration(
                  label: "API URL".text.make(),
                ),
                onChanged: (String value) {
                  box.write('url_api', value);
                },
              ),
            ]),
            16.heightBox,
            VStack([
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
                  SelectableText("Device ID : $deviceId"),
                ],
              ),
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
            ]),
            16.heightBox,
            SelectableText(publicKey),
            16.heightBox,
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    final dio = Dio();
    var response = await dio.post('${box.read('url_api')}/auth/login', data: {
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
