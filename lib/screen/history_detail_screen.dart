import 'package:flutter/material.dart';
import '../models/quiz_history.dart';
import '../theme/app_theme.dart';

class HistoryDetailScreen extends StatelessWidget {
  final QuizHistory history;

  const HistoryDetailScreen({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(context),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Quiz Review",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.builder(
                    itemCount: history.questions.length,
                    itemBuilder: (context, index) {
                      final q = history.questions[index];
                      final bool correct = q.selectedIndex == q.correctIndex;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [AppTheme.getCardShadow(context)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  correct ? Icons.check_circle : Icons.cancel,
                                  color:
                                      correct ? Colors.green : Colors.redAccent,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Q${index + 1}: ${q.title}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.getTextColor(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  q.imageUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...q.options.asMap().entries.map((entry) {
                              final i = entry.key;
                              final option = entry.value;

                              final isCorrectOption = i == q.correctIndex;
                              final isSelected = i == q.selectedIndex;

                              Color bg = Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF7FAFC);

                              if (isCorrectOption) {
                                bg = Colors.green.withOpacity(0.15);
                              } else if (isSelected && !isCorrectOption) {
                                bg = Colors.redAccent.withOpacity(0.15);
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.getTextColor(context),
                                        ),
                                      ),
                                    ),
                                    if (isCorrectOption)
                                      const Icon(Icons.check,
                                          color: Colors.green),
                                    if (isSelected && !isCorrectOption)
                                      const Icon(Icons.close,
                                          color: Colors.redAccent),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
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
