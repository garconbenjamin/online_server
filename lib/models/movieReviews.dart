import 'package:stormberry/stormberry.dart';

part 'movieReviews.schema.dart';

@Model()
abstract class MovieReview {
  @PrimaryKey()
  @AutoIncrement()
  int? get id;
  String? get name;
  String get title;
  String get content;
}
