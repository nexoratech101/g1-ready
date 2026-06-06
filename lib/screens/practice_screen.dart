import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/question_data.dart';
import '../services/storage_service.dart';
import 'quiz_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  Map<String, String?> _scores = {};

  final List<Map<String, dynamic>> _sets = [
    {'title': 'Set 1', 'topic': 'Road Signs',      'id': 'set1', 'icon': Icons.traffic,         'questions': QuestionData.set1},
    {'title': 'Set 2', 'topic': 'Traffic Laws',    'id': 'set2', 'icon': Icons.gavel,            'questions': QuestionData.set2},
    {'title': 'Set 3', 'topic': 'Right of Way',    'id': 'set3', 'icon': Icons.swap_horiz,       'questions': QuestionData.set3},
    {'title': 'Set 4', 'topic': 'Speed Limits',    'id': 'set4', 'icon': Icons.speed,            'questions': QuestionData.set4},
    {'title': 'Set 5', 'topic': 'Parking Rules',   'id': 'set5', 'icon': Icons.local_parking,    'questions': QuestionData.set5},
    {'title': 'Set 6', 'topic': 'Alcohol & Drugs', 'id': 'set6', 'icon': Icons.no_drinks,        'questions': QuestionData.set6},
    {'title': 'Set 7', 'topic': 'Winter Driving',  'id': 'set7', 'icon': Icons.ac_unit,          'questions': QuestionData.set7},
    {'title': 'Set 8', 'topic': 'Mixed Review',    'id': 'set8', 'icon': Icons.quiz,             'questions': QuestionData.set8},
  ];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final scores = <String, String?>{};
    for (final set in _sets) {
      scores[set['id'] as String] = await StorageService.getScore(set['id'] as String);
    }
    setState(() => _scores = scores);
  }

  Color _getScoreColor(String? score) {
    if (score == null) return AppTheme.lightGrey;
    final parts = score.split('/');
    final got = int.parse(parts[0]);
    final total = int.parse(parts[1]);
    final pct = got / total;
    if (pct >= 0.8) return AppTheme.correct;
    if (pct >= 0.5) return AppTheme.warning;
    return AppTheme.incorrect;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(title: const Text('Practice')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.canadianRed),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Complete each set to earn XP and unlock badges. Aim for 80%!',
                        style: const TextStyle(fontSize: 13, color: AppTheme.darkGrey),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('All Practice Sets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sets.length,
                itemBuilder: (context, index) {
                  final set = _sets[index];
                  final score = _scores[set['id'] as String];
                  return _buildSetListCard(context, set, score);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetListCard(BuildContext context, Map<String, dynamic> set, String? score) {
    final scoreColor = _getScoreColor(score);
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              setTitle: set['title'] as String,
              setId: set['id'] as String,
              questions: set['questions'] as dynamic,
            ),
          ),
        );
        _loadScores();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lightGrey, width: 1.5),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.canadianRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(set['icon'] as IconData, color: AppTheme.canadianRed, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(set['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.darkGrey)),
                  Text(set['topic'] as String,
                      style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                  Text('${(set['questions'] as List).length} questions',
                      style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoreColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      score,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (score == null)
                  const Text('Not started',
                      style: TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.mediumGrey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
