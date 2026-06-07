import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/learning_mode_picker.dart';
import 'exam_countdown_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _learningModeId = 'exam_focus';
  DateTime? _examDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final mode = await StorageService.getLearningMode();
    final examDate = await StorageService.getExamDate();
    setState(() {
      _learningModeId = mode;
      _examDate = examDate;
    });
  }

  Future<void> _pickExamDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'When is your G1 exam?',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.canadianRed)),
        child: child!,
      ),
    );
    if (picked != null) {
      await StorageService.setExamDate(picked);
      setState(() => _examDate = picked);
    }
  }

  Future<void> _clearExamDate() async {
    await StorageService.setExamDate(null);
    setState(() => _examDate = null);
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text('This will clear all your XP scores and bookmarks. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await StorageService.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress reset'), backgroundColor: AppTheme.canadianRed),
              );
            },
            child: const Text('Reset', style: TextStyle(color: AppTheme.incorrect)),
          ),
        ],
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

              // ── Learning Mode Dropdown ────────────────────────────────
              _sectionTitle('Learning Mode'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightGrey, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _learningModeId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.canadianRed),
                    items: LearningModes.all.map((mode) => DropdownMenuItem(
                      value: mode.id,
                      child: Row(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: mode.color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Icon(mode.icon, color: mode.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(mode.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkGrey)),
                          Text(mode.description, style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
                        ]),
                      ]),
                    )).toList(),
                    onChanged: (id) async {
                      if (id == null) return;
                      await StorageService.setLearningMode(id);
                      setState(() => _learningModeId = id);
                      // Prompt exam date if switching to exam focus
                      if (id == 'exam_focus' && _examDate == null) {
                        await _pickExamDate();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Exam Date ─────────────────────────────────────────────
              _sectionTitle('Exam Date'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lightGrey, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: AppTheme.canadianRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.calendar_today, color: AppTheme.canadianRed, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('G1 Exam Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkGrey)),
                          Text(
                            _examDate != null
                                ? '${_examDate!.day}/${_examDate!.month}/${_examDate!.year} — ${_examDate!.difference(DateTime.now()).inDays + 1} days left'
                                : 'Not set',
                            style: TextStyle(fontSize: 12, color: _examDate != null ? AppTheme.canadianRed : AppTheme.mediumGrey),
                          ),
                        ],
                      ),
                    ),
                    if (_examDate != null)
                      TextButton(onPressed: _clearExamDate, child: const Text('Clear', style: TextStyle(color: AppTheme.mediumGrey, fontSize: 12))),
                    TextButton(
                      onPressed: _pickExamDate,
                      child: Text(_examDate != null ? 'Change' : 'Set', style: const TextStyle(color: AppTheme.canadianRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Exam Countdown Screen ─────────────────────────────────
              _sectionTitle('Study Tools'),
              _settingsTile(
                icon: Icons.calendar_today,
                color: AppTheme.canadianRed,
                title: 'Exam Countdown Plan',
                subtitle: 'View your day-by-day study plan',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamCountdownScreen())),
              ),
              const SizedBox(height: 24),

              // ── App ───────────────────────────────────────────────────
              _sectionTitle('App'),
              _settingsTile(icon: Icons.info_outline, color: AppTheme.darkGrey, title: 'About G1 Ready', subtitle: 'Version 1.0.0', onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('About G1 Ready'),
                  content: const Text('G1 Ready helps Ontario drivers prepare for their G1 knowledge test.\n\nGood luck on your test! 🍁'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: AppTheme.canadianRed)))],
                ),
              )),
              _settingsTile(icon: Icons.star_outline, color: AppTheme.darkGrey, title: 'Rate the App', subtitle: 'Enjoying G1 Ready? Leave a review!', onTap: () {}),
              const SizedBox(height: 24),

              // ── Progress ──────────────────────────────────────────────
              _sectionTitle('Progress'),
              _settingsTile(icon: Icons.refresh, color: AppTheme.incorrect, title: 'Reset Progress', subtitle: 'Clear all XP scores and bookmarks', onTap: _confirmReset),
              const SizedBox(height: 40),

              Center(
                child: Column(children: [
                  const Icon(Icons.drive_eta, size: 48, color: AppTheme.canadianRed),
                  const SizedBox(height: 8),
                  const Text('G1 Ready 🍁', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.canadianRed)),
                  const SizedBox(height: 4),
                  const Text('Ontario Driver\'s Test Prep', style: TextStyle(fontSize: 13, color: AppTheme.mediumGrey)),
                  const SizedBox(height: 4),
                  const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                ]),
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

  Widget _settingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
