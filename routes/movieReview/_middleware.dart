import 'package:dart_frog/dart_frog.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;
import 'package:stormberry/stormberry.dart';

Handler middleware(Handler handler) {
  return (context) async {
    final db = Database(
      host: '127.0.0.1',
      port: 5432,
      database: 'postgres',
      user: 'postgres',
      password: '',
      useSSL: false,
    );

    final response = await handler
        .use(requestLogger())
        .use(
          fromShelfMiddleware(
            shelf.corsHeaders(
              headers: {
                shelf.ACCESS_CONTROL_ALLOW_ORIGIN: 'http://localhost:61196',
              },
            ),
          ),
        )
        .use(provider<Database>((_) => db))
        .call(context);

    return response;
  };
}
