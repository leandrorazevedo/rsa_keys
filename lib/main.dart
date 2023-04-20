import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rsa/Home.dart';
import 'package:rsa/LoginResultDto.dart';
import 'package:velocity_x/velocity_x.dart';

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
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String alias = 'SuperApp_RSA';

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
            ElevatedButton(
              onPressed: login,
              child: "Login".text.make(),
            )
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    final dio = Dio();
    var response = await dio.post('https://dev.xdatasolucoes.com.br:9091/auth/login', data: {
      'email': emailController.text,
      'password': passwordController.text,
    });
    if (response.statusCode == 200) {
      var login = LoginResult.fromJson(response.data);
      final box = GetStorage();
      box.write('session', login);

      Get.to(const HomeScreen());
    }
  }
}
