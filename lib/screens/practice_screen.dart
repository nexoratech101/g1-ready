import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/question_data.dart';
import '../services/storage_service.dart';
import 'quiz_screen.dart';
import 'marathon_screen.dart';
import 'quick_mode_screen.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});
  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  Map<String, String?> _scores = {};
  String _sortBy = 'importance';
  bool _loading = true;

  final List<Map<String, dynamic>> _sets = [
    {'title': 'Road Signs', 'subtitle': 'Signs shapes and colors', 'id': 'set1', 'icon': Icons.traffic, 'color': const Color(0xFFD52B1E), 'importance': 1, 'questions': QuestionData.set1, 'tag': 'Most Common'},
    {'title': 'Traffic Laws', 'subtitle': 'Speed limits and rules', 'id': 'set2', 'icon': Icons.gavel, 'color': const Color(0xFF1565C0), 'importance': 1, 'questions': QuestionData.set2, 'tag': 'Most Common'},
    {'title': 'Right of Way', 'subtitle': 'Who goes first', 'id': 'set3', 'icon': Icons.swap_horiz, 'color': const Color(0xFF6A1B9A), 'importance': 1, 'questions': QuestionData.set3, 'tag': 'Most Common'},
    {'title': 'Alcohol & Drugs', 'subtitle': 'BAC limits and penalties', 'id': 'set6', 'icon': Icons.no_drinks, 'color': const Color(0xFFE65100), 'importance': 1, 'questions': QuestionData.set6, 'tag': 'Most Common'},
    {'title': 'Speed & Space', 'subtitle': 'Following distance', 'id': 'set4', 'icon': Icons.speed, 'color': const Color(0xFF00695C), 'importance': 2, 'questions': QuestionData.set4, 'tag': 'Common'},
    {'title': 'Parking Rules', 'subtitle': 'Where and how to park', 'id': 'set5', 'icon': Icons.local_parking, 'color': const Color(0xFF283593), 'importance': 2, 'questions': QuestionData.set5, 'tag': 'Common'},
    {'title': 'Winter Driving', 'subtitle': 'Ice snow and fog', 'id': 'set7', 'icon': Icons.ac_unit, 'color': const Color(0xFF0277BD), 'importance': 2, 'questions': QuestionData.set7, 'tag': 'Common'},
    {'title': 'Mixed Review', 'subtitle': 'All topics combined', 'id': 'set8', 'icon': Icons.quiz, 'color': const Color(0xFF4E342E), 'importance': 3, 'questions': QuestionData.set8, 'tag': 'Review'},
  ];

  // Special mode cards shown when filter is selected
  final List<Map<String, dynamic>> _specialModes = [
    {'title': 'Mixed Mode', 'subtitle': 'Random questions from all topics', 'icon': Icons.shuffle, 'color': const Color(0xFF4E342E), 'tag': 'All Topics', 'mode': 'mixed'},
    {'title': 'Marathon', 'subtitle': 'Endless questions no stopping', 'icon': Icons.all_inclusive, 'color': const Color(0xFF6A1B9A), 'tag': 'Endless', 'mode': 'marathon'},
    {'title': 'Quick 5-Min', 'subtitle': '10 rapid questions with timer', 'icon': Icons.bolt, 'color': const Color(0xFF2E7D32), 'tag': '5 Minutes', 'mode': 'quick'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadScores();
  }

  Future<void> _loadAll() async {
    final pinned = await StorageService.getPinnedSort();
    setState(() => _sortBy = pinned);
    await _loadScores();
    setState(() => _loading = false);
  }

  Future<void> _loadScores() async {
    final scores = <String, String?>{};
    for (final set in _sets) {
      scores[set['id'] as String] = await StorageService.getScore(set['id'] as String);
    }
    if (mounted) setState(() => _scores = scores);
  }

  Future<void> _pinSort(String sort) async {
    await StorageService.setPinnedSort(sort);
    setState(() => _sortBy = sort);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pinned: ${_sortLabel(sort)}'),
        backgroundColor: AppTheme.correct,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _sortLabel(String s) {
    switch (s) {
      case 'importance': return 'By Exam Importance';
      case 'not_done':   return 'Not Done First';
      case 'score_low':  return 'Weakest First';
      case 'score_high': return 'Strongest First';
      case 'mixed':      return 'Mixed Mode';
      case 'marathon':   return 'Marathon Mode';
      case 'quick':      return 'Quick 5-Min Mode';
      default:           return 'By Exam Importance';
    }
  }

  bool get _isSpecialMode => ['mixed', 'marathon', 'quick'].contains(_sortBy);

  List<Map<String, dynamic>> get _sortedSets {
    final list = List<Map<String, dynamic>>.from(_sets);
    switch (_sortBy) {
      case 'importance':
        list.sort((a, b) => (a['importance'] as int).compareTo(b['importance'] as int));
        break;
      case 'score_low':
        list.sort((a, b) => _pct(a['id'] as String).compareTo(_pct(b['id'] as String)));
        break;
      case 'score_high':
        list.sort((a, b) => _pct(b['id'] as String).compareTo(_pct(a['id'] as String)));
        break;
      case 'not_done':
        list.sort((a, b) {
          final aDone = _scores[a['id']] != null ? 1 : 0;
          final bDone = _scores[b['id']] != null ? 1 : 0;
          return aDone.compareTo(bDone);
        });
        break;
    }
    return list;
  }

  double _pct(String id) {
    final s = _scores[id];
    if (s == null) return 0;
    final p = s.split('/');
    return int.parse(p[0]) / int.parse(p[1]);
  }

  int _stars(String? score) {
    if (score == null) return 0;
    final p = score.split('/');
    final pct = int.parse(p[0]) / int.parse(p[1]);
    if (pct >= 0.95) return 5;
    if (pct >= 0.80) return 4;
    if (pct >= 0.60) return 3;
    if (pct >= 0.40) return 2;
    if (pct > 0) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.canadianRed)));

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Practice Tests'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppTheme.white),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              _menuItem('importance', 'By Exam Importance', Icons.star, _sortBy == 'importance'),
              _menuItem('not_done',   'Not Done First',     Icons.new_releases, _sortBy == 'not_done'),
              _menuItem('score_low',  'Weakest First',      Icons.trending_down, _sortBy == 'score_low'),
              _menuItem('score_high', 'Strongest First',    Icons.trending_up, _sortBy == 'score_high'),
              const PopupMenuDivider(),
              _menuItem('mixed',    'Mixed Mode',     Icons.shuffle,       _sortBy == 'mixed'),
              _menuItem('marathon', 'Marathon Mode',  Icons.all_inclusive, _sortBy == 'marathon'),
              _menuItem('quick',    'Quick 5-Min',    Icons.bolt,          _sortBy == 'quick'),
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
              // Sort indicator with pin button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        const Icon(Icons.sort, size: 14, color: AppTheme.mediumGrey),
                        const SizedBox(width: 6),
                        Expanded(child: Text(_sortLabel(_sortBy),
                            style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey))),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _pinSort(_sortBy),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.canadianRed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(children: [
                        Icon(Icons.push_pin, size: 14, color: AppTheme.white),
                        SizedBox(width: 4),
                        Text('Pin', style: TextStyle(fontSize: 12, color: AppTheme.white, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Special mode view
              if (_isSpecialMode)
                _buildSpecialModeView()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _sortedSets.length,
                  itemBuilder: (ctx, i) => _buildSetCard(ctx, _sortedSets[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, String label, IconData icon, bool selected) {
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(icon, size: 18, color: selected ? AppTheme.canadianRed : AppTheme.darkGrey),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: selected ? AppTheme.canadianRed : AppTheme.darkGrey, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        if (selected) ...[const Spacer(), const Icon(Icons.check, size: 16, color: AppTheme.canadianRed)],
      ]),
    );
  }

  Widget _buildSpecialModeView() {
    final mode = _specialModes.firstWhere((m) => m['mode'] == _sortBy);
    final color = mode['color'] as Color;

    return Column(
      children: [
        // Mode header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(mode['icon'] as IconData, color: AppTheme.white, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(mode['title'] as String, style: const TextStyle(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(mode['subtitle'] as String, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                  child: Text(mode['tag'] as String, style: const TextStyle(color: AppTheme.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_sortBy == 'marathon') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MarathonScreen()));
                  } else if (_sortBy == 'quick') {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickModeScreen()));
                  } else {
                    // Mixed — launch quiz with all questions shuffled
                    final all = [...QuestionData.set1, ...QuestionData.set2, ...QuestionData.set3, ...QuestionData.set4, ...QuestionData.set5, ...QuestionData.set6, ...QuestionData.set7, ...QuestionData.set8];
                    all.shuffle();
                    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(setTitle: 'Mixed Review', setId: 'mixed', questions: all.take(20).toList())));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.white,
                  foregroundColor: color,
                ),
                child: Text('Start ${mode['title']}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Or pick a specific topic:',
            style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: _sets.length,
          itemBuilder: (ctx, i) => _buildSetCard(ctx, _sets[i]),
        ),
      ],
    );
  }

  Widget _buildSetCard(BuildContext context, Map<String, dynamic> set) {
    final score = _scores[set['id'] as String];
    final stars = _stars(score);
    final color = set['color'] as Color;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => QuizScreen(
            setTitle: set['title'] as String,
            setId: set['id'] as String,
            questions: set['questions'] as dynamic,
          ),
        ));
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
              decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(set['icon'] as IconData, color: AppTheme.white, size: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                    child: Text(set['tag'] as String, style: const TextStyle(color: AppTheme.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(set['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkGrey)),
                      const SizedBox(height: 2),
                      Text(set['subtitle'] as String, style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
                      const SizedBox(height: 4),
                      Text('${(set['questions'] as List).length} questions', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (score != null)
                          Row(children: List.generate(5, (i) => Icon(
                            i < stars ? Icons.star : Icons.star_border,
                            color: i < stars ? AppTheme.gold : AppTheme.mediumGrey,
                            size: 14,
                          ))),
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
