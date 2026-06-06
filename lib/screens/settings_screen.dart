import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/learning_mode_picker.dart';
import 'marathon_screen.dart';
import 'quick_mode_screen.dart';
import 'exam_countdown_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _learningModeId = 'exam_focus';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mode = await StorageService.getLearningMode();
    setState(() => _learningModeId = mode);
  }

  Future<void> _onModeSelected(String id) async {
    await StorageService.setLearningMode(id);
    setState(() => _learningModeId = id);
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will clear all your XP, scores, bookmarks and badges. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await StorageService.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset successfully'), backgroundColor: AppTheme.canadianRed),
              );
            },
            child: const Text('Reset', style: TextStyle(color: AppTheme.incorrect)),
          ),
        ],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About G1 Ready'),
        content: const Text('G1 Ready helps Ontario drivers prepare for their G1 knowledge test.\n\n80 practice questions across 8 topics, exam simulation mode, and progress tracking.\n\nGood luck on your test! 🍁'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: AppTheme.canadianRed)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Learning Mode ────────────────────────────────────────
              LearningModePicker(
                selectedId: _learningModeId,
                onSelected: _onModeSelected,
              ),
              const SizedBox(height: 28),

              // ── Special Practice Modes ───────────────────────────────
              _sectionTitle('Special Practice Modes'),
              const SizedBox(height: 12),
              _modeTile(
                icon: Icons.bolt,
                color: const Color(0xFF2E7D32),
                title: 'Quick 5-Min Mode',
                subtitle: '10 rapid questions — perfect for busy schedules',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickModeScreen())),
              ),
              _modeTile(
                icon: Icons.all_inclusive,
                color: const Color(0xFF6A1B9A),
                title: 'Marathon Mode',
                subtitle: 'Endless questions — test your endurance',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarathonScreen())),
              ),
              _modeTile(
                icon: Icons.calendar_today,
                color: AppTheme.canadianRed,
                title: 'Exam Countdown',
                subtitle: 'Set your exam date and get a day-by-day plan',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamCountdownScreen())),
              ),
              const SizedBox(height: 28),

              // ── App Settings ─────────────────────────────────────────
              _sectionTitle('App'),
              _settingsTile(icon: Icons.info_outline, title: 'About G1 Ready', subtitle: 'Version 1.0.0', onTap: _showAbout),
              _settingsTile(icon: Icons.star_outline, title: 'Rate the App', subtitle: 'Enjoying G1 Ready? Leave a review!', onTap: () {}),
              const SizedBox(height: 20),

              // ── Danger Zone ──────────────────────────────────────────
              _sectionTitle('Progress'),
              _settingsTile(icon: Icons.refresh, title: 'Reset Progress', subtitle: 'Clear all XP scores and bookmarks', onTap: _confirmReset, color: AppTheme.incorrect),
              const SizedBox(height: 40),

              // Footer
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.drive_eta, size: 48, color: AppTheme.canadianRed),
                    const SizedBox(height: 8),
                    const Text('G1 Ready 🍁', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.canadianRed)),
                    const SizedBox(height: 4),
                    const Text('Ontario Driver\'s Test Prep', style: TextStyle(fontSize: 13, color: AppTheme.mediumGrey)),
                    const SizedBox(height: 4),
                    const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.mediumGrey)),
    );
  }

  Widget _modeTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = AppTheme.darkGrey,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.lightGrey, width: 1.5)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.mediumGrey),
        onTap: onTap,
      ),
    );
  }
}
