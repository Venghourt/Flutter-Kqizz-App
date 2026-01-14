import 'package:flutter/material.dart';
import 'package:kqizzapp/models/quiz_category.dart';
import 'history_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final QuizCategory category;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.category,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get resultMessage {
    double percentage = (widget.score / widget.totalQuestions) * 100;

    if (percentage >= 80) {
      return 'Excellent!';
    } else if (percentage >= 60) {
      return 'Good job!';
    } else if (percentage >= 40) {
      return 'Not Bad!';
    } else {
      return 'Better luck next time!';
    }
  }

  Color get resultColor {
    double percentage = (widget.score / widget.totalQuestions) * 100;

    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.blue;
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF1e1e1e) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.grey.shade700;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF121212),
                    resultColor.withOpacity(0.35),
                    const Color(0xFF121212),
                  ]
                : [
                    resultColor.withOpacity(0.8),
                    resultColor,
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
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
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Icon(
                              Icons.emoji_events,
                              size: 80,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              resultMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              "Your Score",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: resultColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${widget.score}',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: resultColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / ${widget.totalQuestions}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: resultColor,
                                ),
                                child: const Text(
                                  "Back Home",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const HistoryScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color: resultColor,
                                    width: 2,
                                  ),
                                  backgroundColor: cardColor,
                                ),
                                child: Text(
                                  "View History",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: resultColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
