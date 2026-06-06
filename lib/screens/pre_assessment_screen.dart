import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../data/question_data.dart';
import '../models/question.dart';
import '../services/storage_service.dart';

class PreAssessmentScreen extends StatefulWidget {
  const PreAssessmentScreen({super.key});

  @override
  State<PreAssessmentScreen> createState() => _PreAssessmentScreenState();
}

class _PreAssessmentScreenState extends State<PreAssessmentScreen> {
  // 10 diagnostic questions — 1-2 from each set
  late final List<Question> _questions;
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _questions = [
      QuestionData.set1[0], // Road Signs
      QuestionData.set1[4], // Traffic lights
      QuestionData.set2[2], // School bus
      QuestionData.set2[4], // Right turn on red
      QuestionData.set3[0], // Four-way stop
      QuestionData.set4[1], // Speed limit urban
      QuestionData.set5[0], // Parking
      QuestionData.set6[0], // BAC limit
      QuestionData.set6[1], // G1 zero tolerance
      QuestionData.set7[0], // Winter tires
    ];
  }

  Question get _current => _questions[_currentIndex];
  bool get _isLast => _currentIndex == _questions.length - 1;

  void _select(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _current.correctIndex) _score++;
    });
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('assessment_done', true);
    await prefs.setInt('assessment_score', _score);
    // Award XP for completing assessment
    await StorageService.addXP(50);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  String get _rankFromScore {
    final pct = _score / _questions.length;
    if (pct >= 0.8) return 'Advanced';
    if (pct >= 0.6) return 'Intermediate';
    if (pct >= 0.4) return 'Learner';
    return 'Beginner';
  }

  Color _optionColor(int index) {
    if (!_answered) return AppTheme.white;
    if (index == _current.correctIndex) return AppTheme.correct;
    if (index == _selectedAnswer) return AppTheme.incorrect;
    return AppTheme.white;
  }

  Color _optionTextColor(int index) {
    if (!_answered) return AppTheme.darkGrey;
    if (index == _current.correctIndex) return AppTheme.white;
    if (index == _selectedAnswer) return AppTheme.white;
    return AppTheme.darkGrey;
  }

  @override
  Widget build(BuildContext context) {
    // Show result screen if on last question and answered
    if (_isLast && _answered && _selectedAnswer != null) {
      return _buildResultScreen();
    }

    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Quick Assessment'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('Skip', style: TextStyle(color: AppTheme.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.lightGrey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Question ${_currentIndex + 1} of ${_questions.length}',
                          style: const TextStyle(fontSize: 13, color: AppTheme.mediumGrey)),
                      Text('Score: $_score',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.canadianRed,
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppTheme.mediumGrey,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.canadianRed),
                    ),
                  ),
                ],
              ),
            ),

            // Question
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(_current.question,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkGrey,
                          )),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(_current.options.length, (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => _select(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _optionColor(i),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _answered && i == _current.correctIndex
                                  ? AppTheme.correct
                                  : _answered && i == _selectedAnswer
                                      ? AppTheme.incorrect
                                      : AppTheme.lightGrey,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _answered &&
                                      (i == _current.correctIndex || i == _selectedAnswer)
                                      ? Colors.white24
                                      : AppTheme.lightGrey,
                                ),
                                child: Center(
                                  child: Text(String.fromCharCode(65 + i),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: _optionTextColor(i),
                                      )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(_current.options[i],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _optionTextColor(i),
                                      fontWeight: FontWeight.w500,
                                    )),
                              ),
                              if (_answered && i == _current.correctIndex)
                                const Icon(Icons.check_circle, color: AppTheme.white, size: 20),
                              if (_answered && i == _selectedAnswer && i != _current.correctIndex)
                                const Icon(Icons.cancel, color: AppTheme.white, size: 20),
                            ],
                          ),
                        ),
                      ),
                    )),
                    if (_answered)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.highlight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.warning),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb, color: AppTheme.warning, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_current.explanation,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.darkGrey,
                                  )),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            if (_answered && !_isLast)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _next,
                  child: const Text('Next Question'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final pct = _score / _questions.length;
    final rank = _rankFromScore;
    final color = pct >= 0.8
        ? AppTheme.correct
        : pct >= 0.6
            ? AppTheme.warning
            : AppTheme.canadianRed;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      pct >= 0.8 ? Icons.emoji_events : Icons.school,
                      size: 64,
                      color: AppTheme.white,
                    ),
                    const SizedBox(height: 12),
                    const Text('Assessment Complete!',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _resultStat('$_score/${_questions.length}', 'Score'),
                        _resultStat('${(pct * 100).toInt()}%', 'Percentage'),
                        _resultStat(rank, 'Level'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      pct >= 0.8
                          ? 'Impressive! You already know a lot. Head straight to Practice Tests to fine-tune!'
                          : pct >= 0.6
                              ? 'Good start! Review the Learn section for key topics then jump into Practice Tests.'
                              : 'No worries — everyone starts somewhere! Begin with the Learn tab to build your foundation.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.darkGrey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('+50 XP earned for completing assessment!',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.canadianRed,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _finish,
                child: const Text("Let's Go! 🍁"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resultStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
