import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../data/question_data.dart';
import 'quiz_screen.dart';
import 'exam_screen.dart';

class ExamCountdownScreen extends StatefulWidget {
  const ExamCountdownScreen({super.key});
  @override
  State<ExamCountdownScreen> createState() => _ExamCountdownScreenState();
}

class _ExamCountdownScreenState extends State<ExamCountdownScreen> {
  DateTime? _examDate;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('exam_date');
    if (s != null) setState(() => _examDate = DateTime.parse(s));
    setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.canadianRed)), child: child!),
    );
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('exam_date', picked.toIso8601String());
      setState(() => _examDate = picked);
    }
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exam_date');
    setState(() => _examDate = null);
  }

  int get _daysLeft => _examDate == null ? 0 : _examDate!.difference(DateTime.now()).inDays + 1;

  String get _mode {
    final d = _daysLeft;
    if (d <= 0) return 'Exam Day 🏁';
    if (d <= 2) return 'Final Push 🚨';
    if (d <= 3) return 'Crunch Time 🔴';
    if (d <= 7) return 'Intensive 🟠';
    if (d <= 14) return 'Focused 🟡';
    return 'Comfortable 🟢';
  }

  Color get _color {
    final d = _daysLeft;
    if (d <= 3) return AppTheme.incorrect;
    if (d <= 7) return AppTheme.warning;
    if (d <= 14) return const Color(0xFFFF8F00);
    return AppTheme.correct;
  }

  String get _advice {
    final d = _daysLeft;
    if (d <= 0) return 'Today is your exam! Do a quick confidence quiz and go ace it!';
    if (d <= 2) return 'Focus only on top 20 most tested questions. No new content!';
    if (d <= 3) return 'Critical topics only. Take a mock test today. 15-20 min max.';
    if (d <= 7) return 'Heavy practice focus. Take a mock test every 2 days. Review weak areas.';
    if (d <= 14) return 'Core + Important content daily. One mock test this week.';
    return 'Plenty of time! Work through all 8 topics systematically.';
  }

  List<Map<String, dynamic>> get _plan {
    final d = _daysLeft;
    if (d <= 3) return [
      {'task': 'Road Signs Practice', 'icon': Icons.traffic},
      {'task': 'Traffic Laws Practice', 'icon': Icons.gavel},
      {'task': 'Right of Way Practice', 'icon': Icons.swap_horiz},
    ];
    if (d <= 7) return [
      {'task': 'Full Mock Exam (40Q)', 'icon': Icons.assignment},
      {'task': 'Alcohol & Drugs Practice', 'icon': Icons.no_drinks},
      {'task': 'Review weak topics', 'icon': Icons.rate_review},
    ];
    return [
      {'task': 'Read 2 Core Topics in Learn', 'icon': Icons.menu_book},
      {'task': 'Complete 1 Practice Quiz', 'icon': Icons.quiz},
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.canadianRed)));
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Exam Countdown'),
        actions: [if (_examDate != null) IconButton(icon: const Icon(Icons.edit_calendar), onPressed: _pickDate)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _examDate == null ? _noDate() : _withDate(),
        ),
      ),
    );
  }

  Widget _noDate() => Column(
    children: [
      const SizedBox(height: 40),
      Container(width: 120, height: 120, decoration: BoxDecoration(color: AppTheme.canadianRed, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.canadianRed.withOpacity(0.3), blurRadius: 20, offset: const Offset(0,8))]), child: const Icon(Icons.calendar_today, size: 56, color: AppTheme.white)),
      const SizedBox(height: 32),
      const Text('Set Your Exam Date', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
      const SizedBox(height: 12),
      const Text('Tell us when your G1 exam is and we will build a personalized day-by-day study plan.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: AppTheme.mediumGrey, height: 1.5)),
      const SizedBox(height: 40),
      ElevatedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today), label: const Text('Set My Exam Date')),
    ],
  );

  Widget _withDate() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: _color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,4))]),
        child: Column(
          children: [
            Text(_daysLeft <= 0 ? 'TODAY!' : '$_daysLeft', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppTheme.white)),
            if (_daysLeft > 0) const Text('days until your G1 exam', style: TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: Text(_mode, style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 14))),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.canadianRed, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Exam Date', style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
              Text('${_examDate!.day}/${_examDate!.month}/${_examDate!.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.darkGrey)),
            ])),
            TextButton(onPressed: _clear, child: const Text('Clear', style: TextStyle(color: AppTheme.canadianRed))),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: _color.withOpacity(0.3))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.tips_and_updates, color: _color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(_advice, style: TextStyle(fontSize: 13, color: _color, height: 1.4))),
        ]),
      ),
      const SizedBox(height: 24),
      const Text("Today's Study Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
      const SizedBox(height: 12),
      ..._plan.map((t) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.lightGrey, width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0,2))]),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.canadianRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(t['icon'] as IconData, color: AppTheme.canadianRed, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(t['task'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.darkGrey))),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.mediumGrey),
        ]),
      )),
      const SizedBox(height: 24),
      const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(setTitle: 'Road Signs', setId: 'set1', questions: QuestionData.set1))),
            child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 6, offset: const Offset(0,3))]),
              child: const Column(children: [Icon(Icons.quiz, color: AppTheme.white, size: 28), SizedBox(height: 8), Text('Practice Quiz', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 13))])),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamScreen())),
            child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.darkGrey, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0,3))]),
              child: const Column(children: [Icon(Icons.assignment, color: AppTheme.white, size: 28), SizedBox(height: 8), Text('Mock Exam', style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 13))])),
          )),
        ],
      ),
    ],
  );
}
