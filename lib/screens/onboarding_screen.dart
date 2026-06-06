import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.drive_eta,
      'title': 'Welcome to G1 Ready 🍁',
      'subtitle': 'Your complete Ontario G1 test prep companion',
      'body': 'Study smarter, practice more, and pass your G1 knowledge test with confidence.',
      'color': AppTheme.canadianRed,
    },
    {
      'icon': Icons.menu_book,
      'title': 'Learn & Practice',
      'subtitle': 'Everything you need in one app',
      'body': '14 study topics organized by exam importance, 80 practice questions across 8 categories, and a full exam simulation.',
      'color': const Color(0xFF1565C0),
    },
    {
      'icon': Icons.emoji_events,
      'title': 'Stay Motivated',
      'subtitle': 'Gamified learning keeps you going',
      'body': 'Earn XP, unlock badges, climb the rank ladder from Beginner to Expert, and track your daily streak.',
      'color': const Color(0xFF2E7D32),
    },
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/preassessment');
    }
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: const Text('Skip',
                    style: TextStyle(color: AppTheme.mediumGrey, fontSize: 15)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  final color = page['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(page['icon'] as IconData,
                              size: 72, color: AppTheme.white),
                        ),
                        const SizedBox(height: 48),
                        Text(page['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGrey,
                            )),
                        const SizedBox(height: 12),
                        Text(page['subtitle'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: color,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 16),
                        Text(page['body'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.mediumGrey,
                              height: 1.5,
                            )),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppTheme.canadianRed : AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _finish();
                  }
                },
                child: Text(
                  _currentPage < _pages.length - 1 ? 'Next' : 'Take Quick Assessment',
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_currentPage == _pages.length - 1)
              TextButton(
                onPressed: _skip,
                child: const Text('Skip Assessment — Go to App',
                    style: TextStyle(color: AppTheme.mediumGrey)),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
