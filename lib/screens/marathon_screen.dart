import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/question_data.dart';
import '../models/question.dart';
import '../services/storage_service.dart';

class MarathonScreen extends StatefulWidget {
  const MarathonScreen({super.key});
  @override
  State<MarathonScreen> createState() => _MarathonScreenState();
}

class _MarathonScreenState extends State<MarathonScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    final all = [...QuestionData.set1, ...QuestionData.set2, ...QuestionData.set3, ...QuestionData.set4, ...QuestionData.set5, ...QuestionData.set6, ...QuestionData.set7, ...QuestionData.set8];
    all.shuffle();
    _questions = all;
  }

  Question get _current => _questions[_currentIndex % _questions.length];

  void _select(int i) {
    if (_answered) return;
    final correct = i == _current.correctIndex;
    setState(() {
      _selectedAnswer = i; _answered = true; _total++;
      if (correct) { _score++; _streak++; if (_streak > _bestStreak) _bestStreak = _streak; }
      else { _streak = 0; }
    });
  }

  Future<void> _next() async {
    await StorageService.addXP(5);
    setState(() { _currentIndex++; _selectedAnswer = null; _answered = false; });
  }

  void _quit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('End Marathon?'),
        content: Text('Answered: $_total\nCorrect: $_score\nBest Streak: $_bestStreak'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep Going')),
          TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text('End', style: TextStyle(color: AppTheme.canadianRed))),
        ],
      ),
    );
  }

  Color _oc(int i) { if (!_answered) return AppTheme.white; if (i == _current.correctIndex) return AppTheme.correct; if (i == _selectedAnswer) return AppTheme.incorrect; return AppTheme.white; }
  Color _otc(int i) { if (!_answered) return AppTheme.darkGrey; if (i == _current.correctIndex) return AppTheme.white; if (i == _selectedAnswer) return AppTheme.white; return AppTheme.darkGrey; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Marathon Mode'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _quit),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text('$_streak', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppTheme.lightGrey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('$_total', 'Done', Icons.quiz),
                  _stat('$_score', 'Correct', Icons.check_circle),
                  _stat('$_bestStreak', 'Best', Icons.emoji_events),
                  _stat(_total > 0 ? '${((_score/_total)*100).toInt()}%' : '0%', 'Accuracy', Icons.percent),
                ],
              ),
            ),
            if (_streak >= 3)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: AppTheme.warning,
                child: Text('🔥 $_streak in a row! Keep going!', textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
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
              child: ElevatedButton(onPressed: _next, child: const Text('Next Question →')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String v, String l, IconData icon) => Column(children: [
    Icon(icon, color: AppTheme.canadianRed, size: 16),
    const SizedBox(height: 2),
    Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.darkGrey)),
    Text(l, style: const TextStyle(fontSize: 9, color: AppTheme.mediumGrey)),
  ]);
}
