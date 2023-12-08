import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Future<Response> onRequest(RequestContext context) async {
  final students = <Map<String, dynamic>>[];
  final results =
      await context.read<PostgreSQLConnection>().query('SELECT * FROM student');
  for (final row in results) {
    students.add({
      'id': row[0],
      'name': row[1],
      'age': row[2],
      'className': row[3],
    });
  }
  return Response.json(body: students);
}
