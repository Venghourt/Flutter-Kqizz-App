import 'dart:math';
import 'package:kqizzapp/models/difficulty.dart';

import '../models/answer.dart';
import '../models/question.dart';
import '../models/quiz.dart';
import 'quiz_json_loader.dart';

class QuizGeneratorService {
  final _random = Random();

  Future<Quiz> generateQuiz({
    required String categoryId,
    required Difficulty difficulty,
    int questionCount = 10,
  }) async {
    final data = await QuizJsonLoader.load();

    final List<dynamic> sourceList = (categoryId == "country")
        ? (data["countries"] as List)
        : (data["animals"] as List);

    final filtered = sourceList
        .where((e) =>
            (e["difficulty"] as String).toLowerCase() ==
            difficulty.label.toLowerCase())
        .toList();

    if (filtered.length < 4) {
      throw Exception(
        "Not enough data for $categoryId - ${difficulty.label}. Need at least 4 items, found ${filtered.length}",
      );
    }

    filtered.shuffle(_random);

    final count = filtered.length < questionCount ? filtered.length : questionCount;
    final used = filtered.take(count).toList();

    final questions = used.map((item) {
      return _buildQuestion(
        item: item as Map<String, dynamic>,
        allItems: filtered.cast<Map<String, dynamic>>(),
        categoryId: categoryId,
      );
    }).toList();

    return Quiz(
      categoryId: categoryId,
      difficulty: difficulty,
      questions: questions,
    );
  }

  Question _buildQuestion({
    required Map<String, dynamic> item,
    required List<Map<String, dynamic>> allItems,
    required String categoryId,
  }) {
    final correctName = item["name"] as String;

    final wrongPool = allItems
        .where((e) => e["id"] != item["id"])
        .toList()
      ..shuffle(_random);

    final wrong = wrongPool.take(3).toList();

    final answers = <Answer>[
      Answer(text: correctName, isCorrect: true),
      ...wrong.map((e) => Answer(text: e["name"] as String, isCorrect: false)),
    ]..shuffle(_random);

    return Question(
      title: categoryId == "country"
          ? "Which country is this flag?"
          : "Which animal is this?",
      imageUrl: item["image"] as String,
      answers: answers,
    );
  }
}
