import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kqizzapp/models/difficulty.dart';
import 'package:kqizzapp/models/quiz_category.dart';
import 'package:kqizzapp/screen/difficulty_screen.dart';
import 'package:kqizzapp/screen/history_screen.dart';
import 'package:kqizzapp/widget/category_card.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'quiz_screen.dart';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<QuizCategory> categories = [
    QuizCategory(
      name: 'Country',
      icon: Icons.flag,
      color: Colors.blue,
      description: 'Questions about countries, capitals, flags.',
      questionCount: 10,
    ),
    QuizCategory(
      name: 'Animal',
      icon: Icons.pets,
      color: Colors.lightGreen,
      description: 'Questions about animal.',
      questionCount: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void toQuizScreenRandom() {
    HapticFeedback.lightImpact();

    final randomCategory = categories[Random().nextInt(categories.length)];
    final randomDifficulty =
        Difficulty.values[Random().nextInt(Difficulty.values.length)];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizScreen(category: randomCategory, difficulty: randomDifficulty),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(context),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daily Kqizz for You',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.getSubtextColor(context),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [

                            IconButton(
                              onPressed: () {
                                themeProvider.toggleTheme();
                                HapticFeedback.lightImpact();
                              },
                              icon: Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                color: isDarkMode ? Colors.amber : Colors.deepPurple,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? Colors.grey[800]
                                    : const Color(0xFFedf2f7),
                              ),
                            ),
                            const SizedBox(width: 8),

                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HistoryScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.history,
                                color: Colors.deepPurple,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? Colors.grey[800]
                                    : const Color(0xFFedf2f7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),


                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildStatsCard(context),
                  ),
                  const SizedBox(height: 32),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildQuickStartCard(context),
                  ),
                  const SizedBox(height: 32),


                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Choose your category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SlideTransition(
                    position: _slideAnimation,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Categorycard(
                          category: categories[index],
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DifficultyScreen(
                                  category: categories[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
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

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Question',
              '50+',
              Icons.quiz,
              Colors.deepPurple,
              context,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]
                : Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'Categories',
              '2',
              Icons.category,
              const Color(0xFF4ecdc4),
              context,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[700]
                : Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'Difficulty',
              'Mixed',
              Icons.star,
              const Color.fromARGB(255, 255, 207, 62),
              context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppTheme.getCardShadow(context)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Start',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Jump into the random quiz and challenge yourself!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getSubtextColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: toQuizScreenRandom,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Start Kqizz',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.getSubtextColor(context),
          ),
        ),
      ],
    );
  }
}