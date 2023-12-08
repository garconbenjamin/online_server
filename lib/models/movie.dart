import 'package:stormberry/stormberry.dart';

part 'movie.schema.dart';

@Model()
abstract class Movie {
  @PrimaryKey()
  @AutoIncrement()
  int? get id;

  String get title;
}
