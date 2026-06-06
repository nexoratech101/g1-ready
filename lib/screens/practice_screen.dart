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
  String _sortBy = 'importance';

  final List<Map<String, dynamic>> _sets = [
    {'title': 'Road Signs', 'subtitle': 'Signs, shapes & colors', 'id': 'set1', 'icon': Icons.traffic, 'color': const Color(0xFFD52B1E), 'importance': 1, 'questions': QuestionData.set1, 'tag': 'Most Common'},
    {'title': 'Traffic Laws', 'subtitle': 'Speed limits & rules', 'id': 'set2', 'icon': Icons.gavel, 'color': const Color(0xFF1565C0), 'importance': 1, 'questions': QuestionData.set2, 'tag': 'Most Common'},
    {'title': 'Right of Way', 'subtitle': 'Who goes first', 'id': 'set3', 'icon': Icons.swap_horiz, 'color': const Color(0xFF6A1B9A), 'importance': 1, 'questions': QuestionData.set3, 'tag': 'Most Common'},
    {'title': 'Alcohol & Drugs', 'subtitle': 'BAC limits & penalties', 'id': 'set6', 'icon': Icons.no_drinks, 'color': const Color(0xFFE65100), 'importance': 1, 'questions': QuestionData.set6, 'tag': 'Most Common'},
    {'title': 'Speed & Space', 'subtitle': 'Following distance', 'id': 'set4', 'icon': Icons.speed, 'color': const Color(0xFF00695C), 'importance': 2, 'questions': QuestionData.set4, 'tag': 'Common'},
    {'title': 'Parking Rules', 'subtitle': 'Where & how to park', 'id': 'set5', 'icon': Icons.local_parking, 'color': const Color(0xFF283593), 'importance': 2, 'questions': QuestionData.set5, 'tag': 'Common'},
    {'title': 'Winter Driving', 'subtitle': 'Ice, snow & fog', 'id': 'set7', 'icon': Icons.ac_unit, 'color': const Color(0xFF0277BD), 'importance': 2, 'questions': QuestionData.set7, 'tag': 'Common'},
    {'title': 'Mixed Review', 'subtitle': 'All topics combined', 'id': 'set8', 'icon': Icons.quiz, 'color': const Color(0xFF4E342E), 'importance': 3, 'questions': QuestionData.set8, 'tag': 'Review'},
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

  List<Map<String, dynamic>> get _sortedSets {
    final sorted = List<Map<String, dynamic>>.from(_sets);
    switch (_sortBy) {
      case 'importance':
        sorted.sort((a, b) => (a['importance'] as int).compareTo(b['importance'] as int));
        break;
      case 'score_low':
        sorted.sort((a, b) => _getScorePercent(a['id'] as String).compareTo(_getScorePercent(b['id'] as String)));
        break;
      case 'score_high':
        sorted.sort((a, b) => _getScorePercent(b['id'] as String).compareTo(_getScorePercent(a['id'] as String)));
        break;
      case 'not_done':
        sorted.sort((a, b) {
          final aDone = _scores[a['id']] != null ? 1 : 0;
          final bDone = _scores[b['id']] != null ? 1 : 0;
          return aDone.compareTo(bDone);
        });
        break;
    }
    return sorted;
  }

  double _getScorePercent(String id) {
    final score = _scores[id];
    if (score == null) return 0;
    final parts = score.split('/');
    return int.parse(parts[0]) / int.parse(parts[1]);
  }

  // Convert score percentage to 0-5 stars
  int _getStars(String? score) {
    if (score == null) return 0;
    final parts = score.split('/');
    final pct = int.parse(parts[0]) / int.parse(parts[1]);
    if (pct >= 0.95) return 5;
    if (pct >= 0.80) return 4;
    if (pct >= 0.60) return 3;
    if (pct >= 0.40) return 2;
    if (pct > 0) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final sets = _sortedSets;
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Practice Tests'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppTheme.white),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'importance', child: Text('By Exam Importance')),
              const PopupMenuItem(value: 'not_done', child: Text('Not Done First')),
              const PopupMenuItem(value: 'score_low', child: Text('Weakest First')),
              const PopupMenuItem(value: 'score_high', child: Text('Strongest First')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort, size: 14, color: AppTheme.mediumGrey),
                    const SizedBox(width: 6),
                    Text(
                      _sortBy == 'importance' ? 'Sorted by: Exam Importance' :
                      _sortBy == 'not_done' ? 'Sorted by: Not Done First' :
                      _sortBy == 'score_low' ? 'Sorted by: Weakest First' : 'Sorted by: Strongest First',
                      style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: sets.length,
                itemBuilder: (context, index) => _buildSetCard(context, sets[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetCard(BuildContext context, Map<String, dynamic> set) {
    final score = _scores[set['id'] as String];
    final stars = _getStars(score);
    final color = set['color'] as Color;
    final tag = set['tag'] as String;

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
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lightGrey, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(set['icon'] as IconData, color: AppTheme.white, size: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                    child: Text(tag, style: const TextStyle(color: AppTheme.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(set['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkGrey)),
                        const SizedBox(height: 2),
                        Text(set['subtitle'] as String,
                            style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
                        const SizedBox(height: 4),
                        Text('${(set['questions'] as List).length} questions',
                            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (score != null)
                          Row(
                            children: List.generate(5, (i) => Icon(
                              i < stars ? Icons.star : Icons.star_border,
                              color: i < stars ? AppTheme.gold : AppTheme.mediumGrey,
                              size: 14,
                            )),
                          ),
                        if (score == null)
                          const Text('Not started', style: TextStyle(fontSize: 10, color: AppTheme.mediumGrey)),
                        Icon(Icons.arrow_forward_ios, size: 12, color: color),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
