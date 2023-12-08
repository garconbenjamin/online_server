import 'package:dart_frog/dart_frog.dart';
import 'package:online_server/models/movieReviews.dart';
import 'package:stormberry/stormberry.dart';

Future<Response> getAllMovieReview(RequestContext context) async {
  final db = context.read<Database>();
  final result = [];
  final movieReviews = await db.movieReviews.queryMovieReviews();

  for (final row in movieReviews) {
    result.add({
      'id': row.id,
      'name': row.name,
      'title': row.title,
      'content': row.content,
    });
  }

  return Response.json(body: result);
}

Future<Response> createMovieReview(RequestContext context) async {
  final request = context.request;

  final body = await request.formData();
  final fields = body.fields;

  final db = context.read<Database>();
  final id = await db.movieReviews.insertOne(
    MovieReviewInsertRequest(
      name: fields['name'],
      title: fields['title']!,
      content: fields['content']!,
    ),
  );

  return Response.json(
    body: {
      'id': id,
    },
  );
}

Future<Response> updateMovieReview(RequestContext context) async {
  final request = context.request;

  final body = await request.formData();
  final fields = body.fields;

  final db = context.read<Database>();

  await db.movieReviews.updateOne(
    MovieReviewUpdateRequest(
      id: int.parse(fields['id']!),
      name: fields['name'],
      title: fields['title'],
      content: fields['content'],
    ),
  );

  return Response.json(
    body: {
      'message': 'success',
    },
  );
}

Future<Response> deleteMovieReview(RequestContext context) async {
  final request = context.request;

  final body = await request.formData();
  final fields = body.fields;

  final db = context.read<Database>();

  await db.movieReviews.deleteOne(
    int.parse(fields['id']!),
  );

  return Response.json(
    body: {
      'message': 'success',
    },
  );
}

Object onRequest(RequestContext context) {
  switch (context.request.method) {
    case HttpMethod.get:
      return getAllMovieReview(context);
    case HttpMethod.post:
      return createMovieReview(context);
    case HttpMethod.put:
      return updateMovieReview(context);
    case HttpMethod.delete:
      return deleteMovieReview(context);
    default:
      return Response(body: 'Not found', statusCode: 404);
  }
}
