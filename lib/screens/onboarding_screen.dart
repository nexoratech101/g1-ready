import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/learning_mode_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  String _selectedMode = 'exam_focus';

  final int _totalPages = 4; // 3 info slides + 1 mode picker

  Future<void> _setUpDailyTips() async {
    await NotificationService.initialize();
    final granted = await NotificationService.requestPermission();
    if (granted) await NotificationService.scheduleUpcomingTips();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await StorageService.setLearningMode(_selectedMode);
    await _setUpDailyTips();
    if (mounted) Navigator.pushReplacementNamed(context, '/preassessment');
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    await StorageService.setLearningMode(_selectedMode);
    await _setUpDailyTips();
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
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
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildInfoPage(
                    icon: Icons.drive_eta,
                    title: 'Welcome to G1 Ready 🍁',
                    subtitle: 'Your complete Ontario G1 test prep companion',
                    body: 'Study smarter, practice more, and pass your G1 knowledge test with confidence.',
                    color: AppTheme.canadianRed,
                  ),
                  _buildInfoPage(
                    icon: Icons.menu_book,
                    title: 'Learn & Practice',
                    subtitle: 'Everything you need in one app',
                    body: '14 study topics organized by exam importance, 80 practice questions across 8 categories, and a full exam simulation.',
                    color: const Color(0xFF1565C0),
                  ),
                  _buildInfoPage(
                    icon: Icons.emoji_events,
                    title: 'Stay Motivated',
                    subtitle: 'Gamified learning keeps you going',
                    body: 'Earn XP, unlock badges, climb the rank ladder from Beginner to Expert, and track your daily streak.',
                    color: const Color(0xFF2E7D32),
                  ),
                  _buildModePickerPage(),
                ],
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (i) => AnimatedContainer(
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
            const SizedBox(height: 24),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _currentPage < _totalPages - 1
                      ? 'Next'
                      : 'Start Assessment',
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_currentPage == _totalPages - 1)
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

  Widget _buildInfoPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required String body,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: Icon(icon, size: 72, color: AppTheme.white),
          ),
          const SizedBox(height: 48),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
          const SizedBox(height: 12),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Text(body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppTheme.mediumGrey, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildModePickerPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.canadianRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.settings, color: AppTheme.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Choose Your Learning Style',
                          style: TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('You can change this anytime in Settings',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          LearningModePicker(
            selectedId: _selectedMode,
            onSelected: (id) => setState(() => _selectedMode = id),
          ),
        ],
      ),
    );
  }
}
