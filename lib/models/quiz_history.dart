class QuizHistory {
  final String categoryName;   
  final String difficulty; 
  final int score;
  final int totalQuestions;
  final DateTime playedAt;

  final List<QuizHistoryQuestion> questions;

  QuizHistory({
    required this.categoryName,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.playedAt,
    required this.questions,
  });

  Map<String, dynamic> toJson() => {
        "categoryName": categoryName,
        "difficulty": difficulty,
        "score": score,
        "totalQuestions": totalQuestions,
        "playedAt": playedAt.toIso8601String(),
        "questions": questions.map((q) => q.toJson()).toList(),
      };

  factory QuizHistory.fromJson(Map<String, dynamic> json) => QuizHistory(
        categoryName: json["categoryName"],
        difficulty: json["difficulty"],
        score: json["score"],
        totalQuestions: json["totalQuestions"],
        playedAt: DateTime.parse(json["playedAt"]),
        questions: (json["questions"] as List)
            .map((e) => QuizHistoryQuestion.fromJson(e))
            .toList(),
      );
}

class QuizHistoryQuestion {
  final String title;
  final String imageUrl;

  final List<String> options;

  final int correctIndex;

  final int selectedIndex;

  QuizHistoryQuestion({
    required this.title,
    required this.imageUrl,
    required this.options,
    required this.correctIndex,
    required this.selectedIndex,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "imageUrl": imageUrl,
        "options": options,
        "correctIndex": correctIndex,
        "selectedIndex": selectedIndex,
      };

  factory QuizHistoryQuestion.fromJson(Map<String, dynamic> json) =>
      QuizHistoryQuestion(
        title: json["title"],
        imageUrl: json["imageUrl"],
        options: List<String>.from(json["options"]),
        correctIndex: json["correctIndex"],
        selectedIndex: json["selectedIndex"],
      );

  bool get isCorrect => selectedIndex == correctIndex;
}
