import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../data/question_data.dart';
import '../models/question.dart';
import '../services/storage_service.dart';

class QuickModeScreen extends StatefulWidget {
  const QuickModeScreen({super.key});
  @override
  State<QuickModeScreen> createState() => _QuickModeScreenState();
}

class _QuickModeScreenState extends State<QuickModeScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  late Timer _timer;
  int _secondsLeft = 300;

  @override
  void initState() {
    super.initState();
    _buildQuestions();
    _startTimer();
  }

  void _buildQuestions() {
    final all = [...QuestionData.set1, ...QuestionData.set2, ...QuestionData.set3, ...QuestionData.set4, ...QuestionData.set5, ...QuestionData.set6, ...QuestionData.set7, ...QuestionData.set8];
    all.shuffle();
    _questions = all.take(10).toList();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) { _timer.cancel(); _finish(); }
      else { setState(() => _secondsLeft--); }
    });
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  String get _timerText { final m = _secondsLeft ~/ 60; final s = _secondsLeft % 60; return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}'; }
  Color get _timerColor => _secondsLeft <= 60 ? AppTheme.incorrect : _secondsLeft <= 120 ? AppTheme.warning : AppTheme.correct;
  Question get _current => _questions[_currentIndex];
  bool get _isLast => _currentIndex == _questions.length - 1;

  void _select(int i) {
    if (_answered) return;
    setState(() { _selectedAnswer = i; _answered = true; if (i == _current.correctIndex) _score++; });
  }

  Future<void> _next() async {
    if (_isLast) { _finish(); return; }
    setState(() { _currentIndex++; _selectedAnswer = null; _answered = false; });
  }

  Future<void> _finish() async {
    _timer.cancel();
    await StorageService.addXP(_score * 5);
    await StorageService.incrementQuizzes();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(_score >= 8 ? 'Excellent! 🎉' : _score >= 6 ? 'Good work! 👍' : 'Keep Practicing! 💪'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _score >= 8 ? AppTheme.correct : _score >= 6 ? AppTheme.warning : AppTheme.canadianRed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('$_score/10', 'Score'),
                  _stat('${(_score/10*100).toInt()}%', 'Accuracy'),
                  _stat('+${_score*5} XP', 'Earned'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String v, String l) => Column(children: [
    Text(v, style: const TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold)),
    Text(l, style: const TextStyle(color: Colors.white70, fontSize: 11)),
  ]);

  Color _oc(int i) { if (!_answered) return AppTheme.white; if (i == _current.correctIndex) return AppTheme.correct; if (i == _selectedAnswer) return AppTheme.incorrect; return AppTheme.white; }
  Color _otc(int i) { if (!_answered) return AppTheme.darkGrey; if (i == _current.correctIndex) return AppTheme.white; if (i == _selectedAnswer) return AppTheme.white; return AppTheme.darkGrey; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Quick 5-Min Mode'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _timerColor, borderRadius: BorderRadius.circular(20)),
            child: Row(children: [
              const Icon(Icons.timer, color: AppTheme.white, size: 16),
              const SizedBox(width: 4),
              Text(_timerText, style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
            ]),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Question ${_currentIndex+1} of ${_questions.length}', style: const TextStyle(fontSize: 13, color: AppTheme.mediumGrey)),
                      Text('Score: $_score', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.canadianRed)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: (_currentIndex+1)/_questions.length, minHeight: 8, backgroundColor: AppTheme.lightGrey, valueColor: const AlwaysStoppedAnimation(AppTheme.canadianRed)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(16)), child: Text(_current.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.darkGrey))),
                    const SizedBox(height: 20),
                    ...List.generate(_current.options.length, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _select(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _oc(i),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _answered && i == _current.correctIndex ? AppTheme.correct : _answered && i == _selectedAnswer ? AppTheme.incorrect : AppTheme.lightGrey, width: 2),
                          ),
                          child: Row(children: [
                            Container(width: 28, height: 28, decoration: BoxDecoration(shape: BoxShape.circle, color: _answered && (i == _current.correctIndex || i == _selectedAnswer) ? Colors.white24 : AppTheme.lightGrey), child: Center(child: Text(String.fromCharCode(65+i), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _otc(i))))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(_current.options[i], style: TextStyle(fontSize: 15, color: _otc(i), fontWeight: FontWeight.w500))),
                            if (_answered && i == _current.correctIndex) const Icon(Icons.check_circle, color: AppTheme.white, size: 20),
                            if (_answered && i == _selectedAnswer && i != _current.correctIndex) const Icon(Icons.cancel, color: AppTheme.white, size: 20),
                          ]),
                        ),
                      ),
                    )),
                    if (_answered) Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.highlight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.warning)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.lightbulb, color: AppTheme.warning, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_current.explanation, style: const TextStyle(fontSize: 13, color: AppTheme.darkGrey))),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            if (_answered) Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(onPressed: _next, child: Text(_isLast ? 'See Results' : 'Next Question')),
            ),
          ],
        ),
      ),
    );
  }
}
