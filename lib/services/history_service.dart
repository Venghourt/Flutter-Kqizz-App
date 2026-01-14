import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_history.dart';

class HistoryService {
  static const _key = "quiz_history_list";

  static Future<void> addHistory(QuizHistory history) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    list.insert(0, jsonEncode(history.toJson()));

    if (list.length > 50) list.removeRange(50, list.length);

    await prefs.setStringList(_key, list);
  }

  static Future<List<QuizHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    return list.map((e) => QuizHistory.fromJson(jsonDecode(e))).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
