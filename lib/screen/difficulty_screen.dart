import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kqizzapp/models/difficulty.dart';
import 'package:kqizzapp/models/quiz_category.dart';
import 'package:kqizzapp/theme/app_theme.dart';
import 'quiz_screen.dart';

class DifficultyScreen extends StatefulWidget {
  final QuizCategory category;

  const DifficultyScreen({
    super.key,
    required this.category,
  });

  @override
  State<DifficultyScreen> createState() => _DifficultyScreenState();
}

class _DifficultyScreenState extends State<DifficultyScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
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

  void _goToQuiz(Difficulty difficulty) {
    HapticFeedback.lightImpact();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          category: widget.category,
          difficulty: difficulty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getBackgroundGradient(context),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios_new),
                                color: AppTheme.getTextColor(context),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Choose Difficulty',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.getCardColor(context),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [AppTheme.getCardShadow(context)],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: category.color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      category.icon,
                                      color: category.color,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          category.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.getSubtextColor(
                                                context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'Select difficulty',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 14),

                          SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                _DifficultyCard(
                                  title: "Easy",
                                  subtitle: "Famous & simple choices",
                                  icon: Icons.sentiment_satisfied_alt,
                                  color: Colors.green,
                                  onTap: () => _goToQuiz(Difficulty.easy),
                                ),
                                const SizedBox(height: 12),
                                _DifficultyCard(
                                  title: "Medium",
                                  subtitle: "More tricky options",
                                  icon: Icons.trending_up,
                                  color: const Color(0xFFFFCF3E),
                                  onTap: () => _goToQuiz(Difficulty.medium),
                                ),
                                const SizedBox(height: 12),
                                _DifficultyCard(
                                  title: "Hard",
                                  subtitle: "Hard countries / rare animals",
                                  icon: Icons.local_fire_department,
                                  color: Colors.redAccent,
                                  onTap: () => _goToQuiz(Difficulty.hard),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppTheme.getCardShadow(context)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getSubtextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 18, color: AppTheme.getSubtextColor(context)),
          ],
        ),
      ),
    );
  }
}