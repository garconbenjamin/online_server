import 'package:dart_frog/dart_frog.dart';
import 'package:postgres/postgres.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final connection = PostgreSQLConnection('127.0.0.1', 5432, 'postgres',
        username: 'postgres', password: '');
    await connection.open();
    final response = await handler
        .use(provider<PostgreSQLConnection>((_) => connection))
        .call(context);
    await connection.close();
    return response;
  };
}
