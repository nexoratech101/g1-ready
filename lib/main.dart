import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/pre_assessment_screen.dart';
import 'services/notification_service.dart';

void main() {
  runApp(const G1ReadyApp());
}

class G1ReadyApp extends StatelessWidget {
  const G1ReadyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'G1 Ready',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {
        '/home': (_) => const MainScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/preassessment': (_) => const PreAssessmentScreen(),
      },
      home: const SplashRouter(),
    );
  }
}

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    // Show splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    if (!mounted) return;
    if (onboardingDone) {
      // Keep the rotating daily-tip notification window fresh, then
      // show today's fact in-app and go home.
      NotificationService.scheduleUpcomingTips();
      _showDailyFact();
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  Future<void> _showDailyFact() async {
    final prefs = await SharedPreferences.getInstance();
    final dayIndex = DateTime.now().day % 50;
    final facts = [
      'In Ontario you must stop for a school bus with flashing red lights even on a divided highway if there is no raised median.',
      'The default speed limit on Ontario highways is 100 km/h unless otherwise posted.',
      'G1 and G2 drivers must have zero blood alcohol content — any amount is illegal.',
      'You must signal at least 30 metres before making a turn in Ontario.',
      'A flashing red traffic light means treat it as a stop sign.',
      'Ontario fines for speeding in a construction zone are doubled.',
      'You must not park within 3 metres of a fire hydrant in Ontario.',
      'The 3-second rule applies in ideal dry conditions — increase to 6 seconds on ice.',
      'A pennant-shaped sign always indicates a no-passing zone.',
      'You must yield to the vehicle on your right at an uncontrolled intersection.',
    ];
    final fact = facts[dayIndex % facts.length];

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.canadianRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Did You Know? 🍁',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(fact,
            style: const TextStyle(fontSize: 15, color: AppTheme.darkGrey, height: 1.5)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Text('Got it! +15 XP'),
          ),
        ],
      ),
    );

    // Award XP for reading daily fact
    await prefs.setInt('last_fact_day', DateTime.now().day);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.canadianRed,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text('G1',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.canadianRed,
                    )),
              ),
            ),
            const SizedBox(height: 24),
            const Text('G1 Ready',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            const SizedBox(height: 8),
            const Text('Ontario Driver\'s Test Prep',
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
