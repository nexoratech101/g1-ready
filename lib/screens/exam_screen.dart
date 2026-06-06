import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../data/question_data.dart';
import '../models/question.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late List<Question> _questions;
  int _currentIndex = 0;
  List<int?> _selectedAnswers = [];
  bool _answered = false;
  int? _selectedAnswer;

  // Timer
  late Timer _timer;
  int _secondsRemaining = 50 * 60; // 50 minutes

  @override
  void initState() {
    super.initState();
    _prepareQuestions();
    _startTimer();
  }

  void _prepareQuestions() {
    final all = [
      ...QuestionData.set1,
      ...QuestionData.set2,
      ...QuestionData.set3,
      ...QuestionData.set4,
      ...QuestionData.set5,
      ...QuestionData.set6,
      ...QuestionData.set7,
      ...QuestionData.set8,
    ];
    all.shuffle();
    _questions = all.take(40).toList();
    _selectedAnswers = List.filled(40, null);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        _timer.cancel();
        _finishExam();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _timerText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_secondsRemaining <= 300) return AppTheme.incorrect;
    if (_secondsRemaining <= 600) return AppTheme.warning;
    return AppTheme.correct;
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _selectedAnswers[_currentIndex] = index;
    });
  }

  void _nextQuestion() {
    if (_currentIndex == _questions.length - 1) {
      _finishExam();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = _selectedAnswers[_currentIndex];
      _answered = _selectedAnswer != null;
    });
  }

  void _previousQuestion() {
    if (_currentIndex == 0) return;
    setState(() {
      _currentIndex--;
      _selectedAnswer = _selectedAnswers[_currentIndex];
      _answered = _selectedAnswer != null;
    });
  }

  void _finishExam() {
    _timer.cancel();
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i].correctIndex) score++;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          score: score,
          total: _questions.length,
          questions: _questions,
          selectedAnswers: _selectedAnswers,
        ),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit Exam?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Exam'),
          ),
          TextButton(
            onPressed: () {
              _timer.cancel();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit', style: TextStyle(color: AppTheme.canadianRed)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color _getOptionColor(int index) {
    if (!_answered) return AppTheme.white;
    if (index == _questions[_currentIndex].correctIndex) return AppTheme.correct;
    if (index == _selectedAnswer) return AppTheme.incorrect;
    return AppTheme.white;
  }

  Color _getOptionTextColor(int index) {
    if (!_answered) return AppTheme.darkGrey;
    if (index == _questions[_currentIndex].correctIndex) return AppTheme.white;
    if (index == _selectedAnswer) return AppTheme.white;
    return AppTheme.darkGrey;
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;
    final answered = _selectedAnswers.where((a) => a != null).length;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Exam Mode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _confirmExit,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _timerColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: AppTheme.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  _timerText,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} of ${_questions.length}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.mediumGrey),
                      ),
                      Text(
                        '$answered answered',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.canadianRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppTheme.lightGrey,
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
                      child: Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Options
                    ...List.generate(
                      question.options.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _selectAnswer(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getOptionColor(index),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _answered && index == question.correctIndex
                                    ? AppTheme.correct
                                    : _answered && index == _selectedAnswer
                                        ? AppTheme.incorrect
                                        : AppTheme.lightGrey,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _answered &&
                                            (index == question.correctIndex ||
                                                index == _selectedAnswer)
                                        ? Colors.white24
                                        : AppTheme.lightGrey,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + index),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: _getOptionTextColor(index),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    question.options[index],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _getOptionTextColor(index),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (_answered && index == question.correctIndex)
                                  const Icon(Icons.check_circle, color: AppTheme.white, size: 20),
                                if (_answered &&
                                    index == _selectedAnswer &&
                                    index != question.correctIndex)
                                  const Icon(Icons.cancel, color: AppTheme.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Explanation
                    if (_answered)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.highlight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.warning),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb, color: AppTheme.warning, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.explanation,
                                style: const TextStyle(fontSize: 14, color: AppTheme.darkGrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousQuestion,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          side: const BorderSide(color: AppTheme.canadianRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(color: AppTheme.canadianRed),
                        ),
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _answered ? _nextQuestion : null,
                      child: Text(
                        _currentIndex == _questions.length - 1 ? 'Finish Exam' : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final List<Question> questions;
  final List<int?> selectedAnswers;

  const ExamResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.questions,
    required this.selectedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / total;
    final passed = percentage >= 0.8;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Exam Results'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: passed ? AppTheme.correct : AppTheme.canadianRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      passed ? Icons.emoji_events : Icons.refresh,
                      size: 64,
                      color: AppTheme.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      passed ? 'Congratulations!' : 'Keep Practicing!',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      passed ? 'You passed the G1 exam!' : 'You need 80% to pass',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResultStat('$score/$total', 'Score'),
                        _buildResultStat('${(percentage * 100).toInt()}%', 'Percentage'),
                        _buildResultStat(passed ? 'PASS' : 'FAIL', 'Result'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Question Review
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Question Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              ...List.generate(questions.length, (index) {
                final q = questions[index];
                final selected = selectedAnswers[index];
                final correct = selected == q.correctIndex;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: correct ? AppTheme.correct.withOpacity(0.1) : AppTheme.incorrect.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: correct ? AppTheme.correct : AppTheme.incorrect,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        correct ? Icons.check_circle : Icons.cancel,
                        color: correct ? AppTheme.correct : AppTheme.incorrect,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Q${index + 1}: ${q.question}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkGrey,
                              ),
                            ),
                            if (!correct) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Correct: ${q.options[q.correctIndex]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.correct,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
