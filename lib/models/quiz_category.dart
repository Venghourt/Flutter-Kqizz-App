import 'package:flutter/material.dart';

class QuizCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final int questionCount;

  QuizCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.questionCount,
  });
}
