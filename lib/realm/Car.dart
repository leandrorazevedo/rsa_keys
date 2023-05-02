import 'package:realm/realm.dart';

part 'Car.g.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  late ObjectId id;

  late final String make;
  late String? model;
  late int? miles;

  // _Car.fromJson(Map<String, dynamic> json)
  //     : id = json["id"],
  //       make = json['make'],
  //       model = json['model'],
  //       miles = int.parse(json['miles']);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "make": make,
      "model": model,
      "miles": miles.toString(),
    };
  }
}
