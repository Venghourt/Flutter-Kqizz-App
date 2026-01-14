import 'package:flutter/material.dart';

class QuizTimerBar extends StatelessWidget {
  final int secondsLeft;
  final int maxSeconds;
  final Color baseColor;

  const QuizTimerBar({
    super.key,
    required this.secondsLeft,
    required this.maxSeconds,
    required this.baseColor,
  });

  Color get timerColor {
    final ratio = secondsLeft / maxSeconds;

    if (ratio <= 0.3) return Colors.redAccent;
    if (ratio <= 0.6) return const Color(0xFFFFCF3E);
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = secondsLeft / maxSeconds;

    final bgColor = isDark ? const Color(0xFF1e1e1e) : Colors.white;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.45) : Colors.black.withOpacity(0.08);

    final progressBgColor =
        isDark ? Colors.white.withOpacity(0.12) : Colors.grey.shade200;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.timer, color: timerColor),
          const SizedBox(width: 10),
          Text(
            "${secondsLeft}s",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: timerColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: progressBgColor,
                valueColor: AlwaysStoppedAnimation(timerColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
