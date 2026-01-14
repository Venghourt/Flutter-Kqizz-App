import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/history_service.dart';
import '../models/quiz_history.dart';
import 'history_detail_screen.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QuizHistory> _history = [];
  bool _isLoading = true;
  final Set<int> _selectedIndices = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final history = await HistoryService.getHistory();
      setState(() {
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIndices.add(index);
        if (!_isSelectionMode) {
          _isSelectionMode = true;
        }
      }
    });
  }

  void _startSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedIndices.length == _history.length) {
        _selectedIndices.clear();
        _isSelectionMode = false;
      } else {
        _selectedIndices.clear();
        for (int i = 0; i < _history.length; i++) {
          _selectedIndices.add(i);
        }
        _isSelectionMode = true;
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIndices.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected'),
        content: Text('Delete ${_selectedIndices.length} item(s)?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;


    final List<QuizHistory> newHistory = [];
    for (int i = 0; i < _history.length; i++) {
      if (!_selectedIndices.contains(i)) {
        newHistory.add(_history[i]);
      }
    }

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final encoded = newHistory.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList("quiz_history_list", encoded);

    // Update UI
    setState(() {
      _history = newHistory;
      _selectedIndices.clear();
      _isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted ${_selectedIndices.length} item(s)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteSingleItem(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Delete this history item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final List<QuizHistory> newHistory = [];
    for (int i = 0; i < _history.length; i++) {
      if (i != index) {
        newHistory.add(_history[i]);
      }
    }


    final prefs = await SharedPreferences.getInstance();
    final encoded = newHistory.map((h) => jsonEncode(h.toJson())).toList();
    await prefs.setStringList("quiz_history_list", encoded);


    setState(() {
      _history = newHistory;
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('Delete all history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.clearHistory();
      setState(() {
        _history = [];
        _selectedIndices.clear();
        _isSelectionMode = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All history cleared'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            _isSelectionMode ? Icons.close : Icons.arrow_back,
            color: AppTheme.getTextColor(context),
          ),
          onPressed: () {
            if (_isSelectionMode) {
              setState(() {
                _isSelectionMode = false;
                _selectedIndices.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _isSelectionMode 
              ? "${_selectedIndices.length} selected"
              : "History",
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isSelectionMode && _history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.select_all),
              color: AppTheme.getTextColor(context),
              onPressed: _startSelectionMode,
              tooltip: 'Select items',
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteSelected,
              tooltip: 'Delete selected',
            )
          else if (_history.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppTheme.getTextColor(context)),
              onPressed: _clearAllHistory,
              tooltip: 'Clear all history',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(context),
        ),
        child: Column(
          children: [

            if (_isSelectionMode && _history.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Select items to delete",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _selectAll,
                      child: Text(
                        _selectedIndices.length == _history.length
                            ? "Deselect all"
                            : "Select all",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),


            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 80,
                                color: AppTheme.getSubtextColor(context),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No quiz history yet",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.getTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Take some quizzes to see them here",
                                style: TextStyle(
                                  color: AppTheme.getSubtextColor(context),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final h = _history[index];
                              final isSelected = _selectedIndices.contains(index);
                              final percent = (h.score / h.totalQuestions * 100).round();

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: isSelected
                                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                                    : AppTheme.getCardColor(context),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isSelected
                                      ? BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        )
                                      : BorderSide.none,
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [

                                      if (_isSelectionMode)
                                        IconButton(
                                          icon: Icon(
                                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                            color: isSelected 
                                                ? Theme.of(context).primaryColor 
                                                : Colors.grey,
                                            size: 28,
                                          ),
                                          onPressed: () => _toggleSelection(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        )
                                      else

                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.grey,
                                            size: 24,
                                          ),
                                          onPressed: () => _deleteSingleItem(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          tooltip: 'Delete this item',
                                        ),
                                      
                                      const SizedBox(width: 8),
                                      

                                      Expanded(
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(8),
                                          onTap: () {
                                            if (!_isSelectionMode) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => HistoryDetailScreen(history: h),
                                                ),
                                              );
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              children: [

                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(
                                                    Icons.history,
                                                    color: Theme.of(context).primaryColor,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "${h.categoryName} • ${h.difficulty}",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppTheme.getTextColor(context),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _formatDate(h.playedAt),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: AppTheme.getSubtextColor(context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                

                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "${h.score}/${h.totalQuestions}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppTheme.getTextColor(context),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "$percent%",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppTheme.getSubtextColor(context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      

      floatingActionButton: _isSelectionMode && _selectedIndices.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelected,
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.delete),
              label: Text('Delete (${_selectedIndices.length})'),
            )
          : null,
    );
  }
}