import 'answer.dart';

class Question {
  final String title;
  final String imageUrl;
  final List<Answer> answers;

  Question({
    required this.title,
    required this.imageUrl,
    required this.answers,
  });

  List<String> get option => answers.map((a) => a.text).toList();
  int get correctAnswer => answers.indexWhere((a) => a.isCorrect);
}
