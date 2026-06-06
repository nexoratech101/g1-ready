import 'package:flutter/material.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class QuizScreen extends StatefulWidget {
  final String setTitle;
  final String setId;
  final List<Question> questions;

  const QuizScreen({
    super.key,
    required this.setTitle,
    required this.setId,
    required this.questions,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _answered = false;
  int _score = 0;
  bool _isBookmarked = false;

  Question get _currentQuestion => widget.questions[_currentIndex];
  bool get _isLastQuestion => _currentIndex == widget.questions.length - 1;

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    final bookmarked = await StorageService.isBookmarked(_currentQuestion.id);
    setState(() => _isBookmarked = bookmarked);
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _currentQuestion.correctIndex) _score++;
    });
  }

  Future<void> _nextQuestion() async {
    if (_isLastQuestion) {
      await StorageService.saveScore(
          widget.setId, _score, widget.questions.length);
      await StorageService.incrementQuizzes();
      await StorageService.addXP(_score * 10);
      await StorageService.addQuestionsAnswered(widget.questions.length);
      _showResults();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
      _isBookmarked = false;
    });
    _loadBookmark();
  }

  Future<void> _toggleBookmark() async {
    await StorageService.toggleBookmark(_currentQuestion.id);
    setState(() => _isBookmarked = !_isBookmarked);
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultScreen(
          score: _score,
          total: widget.questions.length,
          setTitle: widget.setTitle,
          xpEarned: _score * 10,
        ),
      ),
    );
  }

  Color _getOptionColor(int index) {
    if (!_answered) return AppTheme.white;
    if (index == _currentQuestion.correctIndex) return AppTheme.correct;
    if (index == _selectedAnswer) return AppTheme.incorrect;
    return AppTheme.white;
  }

  Color _getOptionTextColor(int index) {
    if (!_answered) return AppTheme.darkGrey;
    if (index == _currentQuestion.correctIndex) return AppTheme.white;
    if (index == _selectedAnswer) return AppTheme.white;
    return AppTheme.darkGrey;
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_currentIndex + 1) / widget.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(widget.setTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: AppTheme.white,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentIndex + 1} of ${widget.questions.length}',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.mediumGrey),
                      ),
                      Text(
                        'Score: $_score',
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
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.canadianRed),
                    ),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _currentQuestion.question,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(
                      _currentQuestion.options.length,
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
                                color: _answered &&
                                        index == _currentQuestion.correctIndex
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
                                            (index ==
                                                    _currentQuestion
                                                        .correctIndex ||
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
                                    _currentQuestion.options[index],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _getOptionTextColor(index),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (_answered &&
                                    index == _currentQuestion.correctIndex)
                                  const Icon(Icons.check_circle,
                                      color: AppTheme.white, size: 20),
                                if (_answered &&
                                    index == _selectedAnswer &&
                                    index != _currentQuestion.correctIndex)
                                  const Icon(Icons.cancel,
                                      color: AppTheme.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
                            const Icon(Icons.lightbulb,
                                color: AppTheme.warning, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentQuestion.explanation,
                                style: const TextStyle(
                                    fontSize: 14, color: AppTheme.darkGrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_answered)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child:
                      Text(_isLastQuestion ? 'See Results' : 'Next Question'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final String setTitle;
  final int xpEarned;

  const _ResultScreen({
    required this.score,
    required this.total,
    required this.setTitle,
    required this.xpEarned,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = score / total;
    bool passed = percentage >= 0.8;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                passed ? Icons.emoji_events : Icons.refresh,
                size: 80,
                color: passed ? AppTheme.gold : AppTheme.canadianRed,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? 'Great Job!' : 'Keep Practicing!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(setTitle,
                  style: const TextStyle(
                      fontSize: 16, color: AppTheme.mediumGrey)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: passed ? AppTheme.correct : AppTheme.canadianRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      '$score / $total',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style:
                          const TextStyle(fontSize: 20, color: AppTheme.white),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '+$xpEarned XP earned!',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
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
}
