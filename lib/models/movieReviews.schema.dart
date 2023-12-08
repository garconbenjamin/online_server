// ignore_for_file: annotate_overrides

part of 'movieReviews.dart';

extension MovieReviewsRepositories on Database {
  MovieReviewRepository get movieReviews => MovieReviewRepository._(this);
}

abstract class MovieReviewRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<MovieReviewInsertRequest>,
        ModelRepositoryUpdate<MovieReviewUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory MovieReviewRepository._(Database db) = _MovieReviewRepository;

  Future<MovieReviewView?> queryMovieReview(int id);
  Future<List<MovieReviewView>> queryMovieReviews([QueryParams? params]);
}

class _MovieReviewRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<MovieReviewInsertRequest>,
        RepositoryUpdateMixin<MovieReviewUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements MovieReviewRepository {
  _MovieReviewRepository(super.db) : super(tableName: 'movie_reviews', keyName: 'id');

  @override
  Future<MovieReviewView?> queryMovieReview(int id) {
    return queryOne(id, MovieReviewViewQueryable());
  }

  @override
  Future<List<MovieReviewView>> queryMovieReviews([QueryParams? params]) {
    return queryMany(MovieReviewViewQueryable(), params);
  }

  @override
  Future<List<int>> insert(List<MovieReviewInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var values = QueryValues();
    var rows = await db.query(
      'INSERT INTO "movie_reviews" ( "name", "title", "content" )\n'
      'VALUES ${requests.map((r) => '( ${values.add(r.name)}:text, ${values.add(r.title)}:text, ${values.add(r.content)}:text )').join(', ')}\n'
      'RETURNING "id"',
      values.values,
    );
    var result = rows.map<int>((r) => TextEncoder.i.decode(r.toColumnMap()['id'])).toList();

    return result;
  }

  @override
  Future<void> update(List<MovieReviewUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.query(
      'UPDATE "movie_reviews"\n'
      'SET "name" = COALESCE(UPDATED."name", "movie_reviews"."name"), "title" = COALESCE(UPDATED."title", "movie_reviews"."title"), "content" = COALESCE(UPDATED."content", "movie_reviews"."content")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${values.add(r.id)}:int8::int8, ${values.add(r.name)}:text::text, ${values.add(r.title)}:text::text, ${values.add(r.content)}:text::text )').join(', ')} )\n'
      'AS UPDATED("id", "name", "title", "content")\n'
      'WHERE "movie_reviews"."id" = UPDATED."id"',
      values.values,
    );
  }
}

class MovieReviewInsertRequest {
  MovieReviewInsertRequest({
    this.name,
    required this.title,
    required this.content,
  });

  final String? name;
  final String title;
  final String content;
}

class MovieReviewUpdateRequest {
  MovieReviewUpdateRequest({
    required this.id,
    this.name,
    this.title,
    this.content,
  });

  final int id;
  final String? name;
  final String? title;
  final String? content;
}

class MovieReviewViewQueryable extends KeyedViewQueryable<MovieReviewView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => TextEncoder.i.encode(key);

  @override
  String get query => 'SELECT "movie_reviews".*'
      'FROM "movie_reviews"';

  @override
  String get tableAlias => 'movie_reviews';

  @override
  MovieReviewView decode(TypedMap map) => MovieReviewView(
      id: map.getOpt('id'),
      name: map.getOpt('name'),
      title: map.get('title'),
      content: map.get('content'));
}

class MovieReviewView {
  MovieReviewView({
    this.id,
    this.name,
    required this.title,
    required this.content,
  });

  final int? id;
  final String? name;
  final String title;
  final String content;
}
