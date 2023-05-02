import 'dart:async';

import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:velocity_x/velocity_x.dart';

import 'schemas.dart';

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

  Future<void> connectToRealm() async {
    var appConfig = AppConfiguration("poc-realm-xhyak");
    var app = App(appConfig);

    final apiKeyCredentials = Credentials.apiKey("KXjQzhnlwasx3wWhYYRa6CPxebGzrV847x0MyKQCVHCcuWIpYcqMznmOLkjCVbTq");
    final currentUser = await app.logIn(apiKeyCredentials);

    final config = Configuration.flexibleSync(currentUser, [Car.schema]);
    realm = await Realm.open(config);

    // Add subscriptions
    realm.subscriptions.update((mutableSubscriptions) {
      // Get Cars from Atlas that match the Realm Query Language query.
      // Uses the queryable field `miles`.
      // Query matches cars with less than 100 miles or `null` miles.
      final allCars = realm.all<Car>();
      mutableSubscriptions.add(allCars);
    });
    await realm.subscriptions.waitForSynchronization();

    // final config = Configuration.local([Car.schema]);
    // realm = Realm(config);

    allCars = realm.all<Car>();
    subscription = allCars!.changes.listen((event) {
      setState(() {
        carsResult = event.results.toList();
      });
    });
  }

  @override
  void initState() {
    connectToRealm();
    super.initState();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await subscription!.cancel();
    realm.subscriptions.update((MutableSubscriptionSet mutableSubscriptions) {
      mutableSubscriptions.removeByType<Car>();
    });

    realm.close();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(allCars?.length.toString());
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: "Teste Realm".text.make(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
          final car = Car(ObjectId(), 'Tesla', model: 'Model S', miles: 42);
          realm.write(() {
            realm.add(car);
          });
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: carsResult == null
            ? "Lista vazia".text.makeCentered()
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
