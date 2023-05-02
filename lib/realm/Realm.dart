import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:velocity_x/velocity_x.dart';

import 'Car.dart';

class RealmScreen extends StatefulWidget {
  const RealmScreen({Key? key}) : super(key: key);

  @override
  State<RealmScreen> createState() => _RealmScreenState();
}

class _RealmScreenState extends State<RealmScreen> {
  late final Realm realm;

  RealmResults<Car>? allCars;
  List<Car>? carsResult;
  StreamSubscription<RealmResultsChanges<Car>>? subscription;

  @override
  void initState() {
    final config = Configuration.local([Car.schema]);
    realm = Realm(config);

    allCars = realm.all<Car>();
    subscription = allCars!.changes.listen((event) {
      setState(() {
        carsResult = event.results.toList();
      });
    });

    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await subscription!.cancel();
    realm.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: "Teste Realm".text.make(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final car = Car(ObjectId(), 'Tesla', model: 'Model S', miles: 42);
          realm.write(() {
            realm.add(car);
          });
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: carsResult == null
            ? "Liza vazia".text.makeCentered()
            : ListView.builder(
                itemCount: carsResult!.length,
                itemBuilder: (_, index) {
                  return ListTile(
                    trailing: IconButton(
                        onPressed: () {
                          realm.write(() {
                            realm.delete(carsResult![index]);
                          });
                        },
                        icon: const Icon(Icons.delete)),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(carsResult![index].id.toString()),
                        Row(
                          children: [
                            Text(carsResult![index].make),
                            8.widthBox,
                            Text(carsResult![index].model!),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
      ),
    );
  }
}

// ListView.builder(itemBuilder: (context, index) {
// return ListTile(
// title: Text(carsResult?[index-1].model ?? ""),
// );
// }),
