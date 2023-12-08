import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final db = Database(
        host: '127.0.0.1',
        port: 5432,
        database: 'postgres',
        user: 'postgres',
        password: '',
        useSSL: false);

    final response =
        await handler.use(provider<Database>((_) => db)).call(context);

    return response;
  };
}
