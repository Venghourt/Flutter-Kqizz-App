import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kqizzapp/models/difficulty.dart';
import 'package:kqizzapp/models/question.dart';
import 'package:kqizzapp/models/quiz_category.dart';

import '../models/quiz_history.dart';
import '../services/history_service.dart';
import '../services/quiz_generator_service.dart';
import '../widget/answer_card.dart';
import '../widget/quiz_timer_bar.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final QuizCategory category;
  final Difficulty difficulty;

  const QuizScreen({
    super.key,
    required this.category,
    required this.difficulty,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  int selectedAnswer = -1;
  bool isAnswered = false;

  static const int _maxSeconds = 15;
  int _secondsLeft = _maxSeconds;
  Timer? _timer;

  late AnimationController _progressController;
  late AnimationController _questionController;

  final QuizGeneratorService _quizService = QuizGeneratorService();

  List<Question> questions = [];
  bool isLoading = true;

  final List<int> selectedAnswers = [];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _questionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _questionController.forward();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final categoryId =
          widget.category.name.toLowerCase() == "country" ? "country" : "animal";

      final quiz = await _quizService.generateQuiz(
        categoryId: categoryId,
        difficulty: widget.difficulty,
        questionCount: 10,
      );

      if (!mounted) return;

      setState(() {
        questions = quiz.questions;
        isLoading = false;
        currentQuestionIndex = 0;
        score = 0;
        selectedAnswer = -1;
        isAnswered = false;
      });

      selectedAnswers
        ..clear()
        ..addAll(List.filled(questions.length, -1));

      _startTimer();
    } catch (e) {
      debugPrint("Load quiz error: $e");

      if (!mounted) return;

      setState(() {
        questions = [];
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _progressController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void selectAnswer(int answerIndex) {
    if (isAnswered) return;

    _stopTimer();

    setState(() {
      selectedAnswer = answerIndex;
      isAnswered = true;
    });

    selectedAnswers[currentQuestionIndex] = answerIndex;

    HapticFeedback.lightImpact();

    if (answerIndex == questions[currentQuestionIndex].correctAnswer) {
      score++;
    }

    Future.delayed(const Duration(milliseconds: 1200), () async {
      await nextQuestion();
    });
  }

  Future<void> nextQuestion() async {
    if (questions.isEmpty) return;

    _stopTimer();

    if (currentQuestionIndex < questions.length - 1) {
      _questionController.reset();

      setState(() {
        currentQuestionIndex++;
        selectedAnswer = -1;
        isAnswered = false;
      });

      _questionController.forward();

      _progressController.animateTo(
        (currentQuestionIndex + 1) / questions.length,
      );

      _startTimer();
      return;
    }

    if (!mounted) return;

    final historyQuestions = questions.asMap().entries.map((entry) {
      final i = entry.key;
      final q = entry.value;

      return QuizHistoryQuestion(
        title: q.title,
        imageUrl: q.imageUrl,
        options: q.option,
        correctIndex: q.correctAnswer,
        selectedIndex: selectedAnswers[i],
      );
    }).toList();

    await HistoryService.addHistory(
      QuizHistory(
        categoryName: widget.category.name,
        difficulty: widget.difficulty.label,
        score: score,
        totalQuestions: questions.length,
        playedAt: DateTime.now(),
        questions: historyQuestions,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          score: score,
          totalQuestions: questions.length,
          category: widget.category,
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _maxSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return;

      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 0) {
        timer.cancel();

        if (!isAnswered) {
          setState(() {
            isAnswered = true;
            selectedAnswer = -1;
          });

          selectedAnswers[currentQuestionIndex] = -1;
        }

        await Future.delayed(const Duration(milliseconds: 300));
        await nextQuestion();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: widget.category.color),
        ),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No questions found.\nPlease check JSON difficulty/category data.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    final questionCardColor = isDark ? const Color(0xFF1e1e1e) : Colors.white;
    final questionTextColor =
        isDark ? Colors.white : const Color(0xFF2d3748);

    final progressBg = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.grey[300];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF121212),
                    Color(0xFF1E1E1E),
                    Color(0xFF121212),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.category.color.withOpacity(0.1),
                    widget.category.color.withOpacity(0.05),
                  ],
                ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color:
                                isDark ? Colors.white : const Color(0xFF2d3748),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: progressBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor:
                                  (currentQuestionIndex + 1) / questions.length,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.category.color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${currentQuestionIndex + 1}/${questions.length}',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF2d3748),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _questionController,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: questionCardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          question.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: questionTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _questionController,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: isDark
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.06),
                                    Colors.white.withOpacity(0.02),
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    widget.category.color.withOpacity(0.25),
                                    widget.category.color.withOpacity(0.12),
                                  ],
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.55)
                                  : widget.category.color.withOpacity(0.20),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            question.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 90),
                        itemCount: question.option.length,
                        itemBuilder: (context, index) {
                          return FadeTransition(
                            opacity: _questionController,
                            child: AnswerCard(
                              text:
                                  "${String.fromCharCode(65 + index)}. ${question.option[index]}",
                              isSelected: selectedAnswer == index,
                              isCorrect:
                                  isAnswered && index == question.correctAnswer,
                              isWrong: isAnswered &&
                                  index != question.correctAnswer &&
                                  selectedAnswer == index,
                              onTap: () => selectAnswer(index),
                              color: widget.category.color,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: QuizTimerBar(
                    secondsLeft: _secondsLeft,
                    maxSeconds: _maxSeconds,
                    baseColor: widget.category.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
