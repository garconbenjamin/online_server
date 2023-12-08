import 'package:stormberry/stormberry.dart';

import 'models/student.dart';

var db = Database(
  host: '127.0.0.1',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: '',
  useSSL: false,
);
Future<void> test() async {
  await db.students.insertOne(
    StudentInsertRequest(
      id: 1,
      name: 'John',
      age: 18,
      className: 'A',
    ),
  );
}
