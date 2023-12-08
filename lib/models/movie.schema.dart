// ignore_for_file: annotate_overrides

part of 'movie.dart';

extension MovieRepositories on Database {
  MovieRepository get movies => MovieRepository._(this);
}

abstract class MovieRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<MovieInsertRequest>,
        ModelRepositoryUpdate<MovieUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory MovieRepository._(Database db) = _MovieRepository;

  Future<MovieView?> queryMovie(int id);
  Future<List<MovieView>> queryMovies([QueryParams? params]);
}

class _MovieRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<MovieInsertRequest>,
        RepositoryUpdateMixin<MovieUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements MovieRepository {
  _MovieRepository(super.db) : super(tableName: 'movies', keyName: 'id');

  @override
  Future<MovieView?> queryMovie(int id) {
    return queryOne(id, MovieViewQueryable());
  }

  @override
  Future<List<MovieView>> queryMovies([QueryParams? params]) {
    return queryMany(MovieViewQueryable(), params);
  }

  @override
  Future<List<int>> insert(List<MovieInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var values = QueryValues();
    var rows = await db.query(
      'INSERT INTO "movies" ( "title" )\n'
      'VALUES ${requests.map((r) => '( ${values.add(r.title)}:text )').join(', ')}\n'
      'RETURNING "id"',
      values.values,
    );
    var result = rows.map<int>((r) => TextEncoder.i.decode(r.toColumnMap()['id'])).toList();

    return result;
  }

  @override
  Future<void> update(List<MovieUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.query(
      'UPDATE "movies"\n'
      'SET "title" = COALESCE(UPDATED."title", "movies"."title")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${values.add(r.id)}:int8::int8, ${values.add(r.title)}:text::text )').join(', ')} )\n'
      'AS UPDATED("id", "title")\n'
      'WHERE "movies"."id" = UPDATED."id"',
      values.values,
    );
  }
}

class MovieInsertRequest {
  MovieInsertRequest({
    required this.title,
  });

  final String title;
}

class MovieUpdateRequest {
  MovieUpdateRequest({
    required this.id,
    this.title,
  });

  final int id;
  final String? title;
}

class MovieViewQueryable extends KeyedViewQueryable<MovieView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => TextEncoder.i.encode(key);

  @override
  String get query => 'SELECT "movies".*'
      'FROM "movies"';

  @override
  String get tableAlias => 'movies';

  @override
  MovieView decode(TypedMap map) => MovieView(id: map.getOpt('id'), title: map.get('title'));
}

class MovieView {
  MovieView({
    this.id,
    required this.title,
  });

  final int? id;
  final String title;
}
