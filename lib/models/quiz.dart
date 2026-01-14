import 'package:kqizzapp/models/difficulty.dart';
import 'question.dart';

class Quiz {
  final String categoryId;
  final Difficulty difficulty;
  final List<Question> questions;

  Quiz({
    required this.categoryId,
    required this.difficulty,
    required this.questions,
  });
}
