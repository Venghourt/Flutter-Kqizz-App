import 'dart:convert';
import 'package:flutter/services.dart';

class QuizJsonLoader {
  static Future<Map<String, dynamic>> load() async {
    final raw = await rootBundle.loadString("assets/data/quizzes.json");
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
