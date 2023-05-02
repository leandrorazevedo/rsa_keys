import 'package:realm/realm.dart';

part 'schemas.g.dart';

@RealmModel()
class _Car {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;

  late final String make;
  late String? model;
  late int? miles;
}
