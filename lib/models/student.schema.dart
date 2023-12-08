// ignore_for_file: annotate_overrides

part of 'student.dart';

extension StudentRepositories on Database {
  StudentRepository get students => StudentRepository._(this);
}

abstract class StudentRepository
    implements
        ModelRepository,
        ModelRepositoryInsert<StudentInsertRequest>,
        ModelRepositoryUpdate<StudentUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory StudentRepository._(Database db) = _StudentRepository;

  Future<StudentView?> queryStudent(int id);
  Future<List<StudentView>> queryStudents([QueryParams? params]);
}

class _StudentRepository extends BaseRepository
    with
        RepositoryInsertMixin<StudentInsertRequest>,
        RepositoryUpdateMixin<StudentUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements StudentRepository {
  _StudentRepository(super.db) : super(tableName: 'students', keyName: 'id');

  @override
  Future<StudentView?> queryStudent(int id) {
    return queryOne(id, StudentViewQueryable());
  }

  @override
  Future<List<StudentView>> queryStudents([QueryParams? params]) {
    return queryMany(StudentViewQueryable(), params);
  }

  @override
  Future<void> insert(List<StudentInsertRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.query(
      'INSERT INTO "students" ( "id", "name", "age", "class_name" )\n'
      'VALUES ${requests.map((r) => '( ${values.add(r.id)}:int8, ${values.add(r.name)}:text, ${values.add(r.age)}:int8, ${values.add(r.className)}:text )').join(', ')}\n',
      values.values,
    );
  }

  @override
  Future<void> update(List<StudentUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    var values = QueryValues();
    await db.query(
      'UPDATE "students"\n'
      'SET "name" = COALESCE(UPDATED."name", "students"."name"), "age" = COALESCE(UPDATED."age", "students"."age"), "class_name" = COALESCE(UPDATED."class_name", "students"."class_name")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${values.add(r.id)}:int8::int8, ${values.add(r.name)}:text::text, ${values.add(r.age)}:int8::int8, ${values.add(r.className)}:text::text )').join(', ')} )\n'
      'AS UPDATED("id", "name", "age", "class_name")\n'
      'WHERE "students"."id" = UPDATED."id"',
      values.values,
    );
  }
}

class StudentInsertRequest {
  StudentInsertRequest({
    required this.id,
    required this.name,
    required this.age,
    required this.className,
  });

  final int id;
  final String name;
  final int age;
  final String className;
}

class StudentUpdateRequest {
  StudentUpdateRequest({
    required this.id,
    this.name,
    this.age,
    this.className,
  });

  final int id;
  final String? name;
  final int? age;
  final String? className;
}

class StudentViewQueryable extends KeyedViewQueryable<StudentView, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => TextEncoder.i.encode(key);

  @override
  String get query => 'SELECT "students".*'
      'FROM "students"';

  @override
  String get tableAlias => 'students';

  @override
  StudentView decode(TypedMap map) => StudentView(
      id: map.get('id'),
      name: map.get('name'),
      age: map.get('age'),
      className: map.get('class_name'));
}

class StudentView {
  StudentView({
    required this.id,
    required this.name,
    required this.age,
    required this.className,
  });

  final int id;
  final String name;
  final int age;
  final String className;
}
