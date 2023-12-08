import 'package:stormberry/stormberry.dart';

part 'student.schema.dart';

@Model()
abstract class Student {
  @PrimaryKey()
  int get id;
  String get name;
  int get age;
  String get className;
}
