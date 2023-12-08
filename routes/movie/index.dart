import 'package:dart_frog/dart_frog.dart';
import 'package:online_server/models/movie.dart';
import 'package:stormberry/stormberry.dart';

Future<Response> onRequest(RequestContext context) async {
  await context.read<Database>().movies.insertOne(MovieInsertRequest(
        title: 'new movie',
      ));
  return Response(body: 'Success');
}
