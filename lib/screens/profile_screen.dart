import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _xp = 0;
  int _quizzes = 0;
  int _streak = 0;
  int _totalQuestions = 0;
  Map<String, String> _allScores = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final xp = await StorageService.getXP();
    final quizzes = await StorageService.getQuizzesCompleted();
    final streak = await StorageService.getStreak();
    final total = await StorageService.getTotalQuestions();
    final scores = await StorageService.getAllScores();
    setState(() {
      _xp = xp;
      _quizzes = quizzes;
      _streak = streak;
      _totalQuestions = total;
      _allScores = scores;
    });
  }

  String get _rank {
    if (_xp >= 1000) return 'Expert';
    if (_xp >= 600) return 'Advanced';
    if (_xp >= 300) return 'Intermediate';
    if (_xp >= 100) return 'Learner';
    return 'Beginner';
  }

  int get _badges {
    int count = 0;
    if (_quizzes >= 1) count++;
    if (_quizzes >= 5) count++;
    if (_xp >= 100) count++;
    if (_xp >= 300) count++;
    if (_xp >= 600) count++;
    if (_xp >= 1000) count++;
    return count;
  }

  void _showXPBreakdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _XPBreakdownSheet(
        xp: _xp,
        quizzes: _quizzes,
        badges: _badges,
        rank: _rank,
        streak: _streak,
      ),
    );
  }

  // Topic performance analysis
  List<Map<String, dynamic>> get _topicPerformance {
    final setNames = {
      'set1': 'Road Signs',
      'set2': 'Traffic Laws',
      'set3': 'Right of Way',
      'set4': 'Speed & Space',
      'set5': 'Parking Rules',
      'set6': 'Alcohol & Drugs',
      'set7': 'Winter Driving',
      'set8': 'Mixed Review',
    };

    final List<Map<String, dynamic>> result = [];

    for (final entry in setNames.entries) {
      final score = _allScores[entry.key];
      if (score != null) {
        final parts = score.split('/');
        final got = int.parse(parts[0]);
        final total = int.parse(parts[1]);
        final pct = got / total;
        result.add({
          'id': entry.key,
          'name': entry.value,
          'score': score,
          'pct': pct,
          'got': got,
          'total': total,
          'attempted': true,
        });
      } else {
        result.add({
          'id': entry.key,
          'name': entry.value,
          'score': null,
          'pct': 0.0,
          'got': 0,
          'total': 10,
          'attempted': false,
        });
      }
    }

    return result;
  }

  List<Map<String, dynamic>> get _strongTopics =>
      _topicPerformance.where((t) => t['attempted'] == true && t['pct'] >= 0.8).toList()
        ..sort((a, b) => (b['pct'] as double).compareTo(a['pct'] as double));

  List<Map<String, dynamic>> get _weakTopics =>
      _topicPerformance.where((t) => t['attempted'] == true && t['pct'] < 0.8).toList()
        ..sort((a, b) => (a['pct'] as double).compareTo(b['pct'] as double));

  List<Map<String, dynamic>> get _notAttempted =>
      _topicPerformance.where((t) => t['attempted'] == false).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildOverallReadinessCard(),
              const SizedBox(height: 20),
              if (_totalQuestions >= 10) _buildProgressLadder(),
              if (_totalQuestions < 10) _buildNotEnoughData(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.canadianRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(color: AppTheme.white, shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 48, color: AppTheme.canadianRed),
          ),
          const SizedBox(height: 12),
          const Text('G1 Student',
              style: TextStyle(color: AppTheme.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Text('🏆 $_rank',
                    style: const TextStyle(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text('$_streak day streak',
                        style: const TextStyle(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallReadinessCard() {
    final progress = (_xp / 1000).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: _showXPBreakdown,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Overall Readiness',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
                Row(
                  children: [
                    const Icon(Icons.touch_app, size: 14, color: AppTheme.mediumGrey),
                    const SizedBox(width: 2),
                    const Text('Details', style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('$_xp / 1000 XP total',
                style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: AppTheme.mediumGrey,
                valueColor: const AlwaysStoppedAnimation(AppTheme.canadianRed),
              ),
            ),
            const SizedBox(height: 8),
            Text('$percentage% of G1 Ready journey complete',
                style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('$_quizzes', 'Quizzes\nDone', Icons.quiz),
                _buildStat('$_badges', 'Badges\nEarned', Icons.military_tech),
                _buildStat(_rank, 'Current\nRank', Icons.emoji_events),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.canadianRed, size: 20),
        const SizedBox(height: 4),
        Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppTheme.mediumGrey)),
      ],
    );
  }

  Widget _buildNotEnoughData() {
    final remaining = 10 - _totalQuestions;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightGrey),
      ),
      child: Column(
        children: [
          const Icon(Icons.bar_chart, size: 48, color: AppTheme.mediumGrey),
          const SizedBox(height: 12),
          const Text('Progress Ladder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
          const SizedBox(height: 8),
          Text(
            'Answer $remaining more questions to unlock your personalized progress breakdown.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.mediumGrey),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _totalQuestions / 10,
              minHeight: 8,
              backgroundColor: AppTheme.mediumGrey,
              valueColor: const AlwaysStoppedAnimation(AppTheme.canadianRed),
            ),
          ),
          const SizedBox(height: 8),
          Text('$_totalQuestions / 10 questions answered',
              style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
        ],
      ),
    );
  }

  Widget _buildProgressLadder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress Ladder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
        const SizedBox(height: 4),
        const Text('Based on your quiz results so far',
            style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
        const SizedBox(height: 16),

        // Performing Well
        if (_strongTopics.isNotEmpty) ...[
          _buildLadderSectionHeader(
            '✅ Performing Well',
            'Keep it up!',
            AppTheme.correct,
          ),
          const SizedBox(height: 8),
          ..._strongTopics.map((t) => _buildLadderTile(t, AppTheme.correct, true)),
          const SizedBox(height: 16),
        ],

        // Needs Work
        if (_weakTopics.isNotEmpty) ...[
          _buildLadderSectionHeader(
            '⚠️ Needs More Practice',
            'Focus on these topics',
            AppTheme.warning,
          ),
          const SizedBox(height: 8),
          ..._weakTopics.map((t) => _buildLadderTile(t, AppTheme.warning, false)),
          const SizedBox(height: 16),
        ],

        // Not Attempted
        if (_notAttempted.isNotEmpty) ...[
          _buildLadderSectionHeader(
            '🔲 Not Yet Attempted',
            'Try these next',
            AppTheme.mediumGrey,
          ),
          const SizedBox(height: 8),
          ..._notAttempted.map((t) => _buildNotAttemptedTile(t)),
        ],
      ],
    );
  }

  Widget _buildLadderSectionHeader(String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: color.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLadderTile(Map<String, dynamic> topic, Color color, bool isStrong) {
    final pct = topic['pct'] as double;
    final stars = pct >= 0.95 ? 5 : pct >= 0.8 ? 4 : pct >= 0.6 ? 3 : pct >= 0.4 ? 2 : 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkGrey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(5, (i) => Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      color: i < stars ? AppTheme.gold : AppTheme.mediumGrey,
                      size: 14,
                    )),
                    const SizedBox(width: 6),
                    Text('${topic['got']}/${topic['total']} correct',
                        style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${(pct * 100).toInt()}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotAttemptedTile(Map<String, dynamic> topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(topic['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.mediumGrey)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.mediumGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Not started',
                style: TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
          ),
        ],
      ),
    );
  }
}

// ── XP Breakdown Sheet ────────────────────────────────────────────────────
class _XPBreakdownSheet extends StatelessWidget {
  final int xp;
  final int quizzes;
  final int badges;
  final String rank;
  final int streak;

  const _XPBreakdownSheet({
    required this.xp,
    required this.quizzes,
    required this.badges,
    required this.rank,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Total XP Earned', 'value': '$xp / 1000 XP', 'icon': Icons.star, 'color': AppTheme.canadianRed},
      {'label': 'Quizzes Completed', 'value': '$quizzes', 'icon': Icons.quiz, 'color': const Color(0xFF1565C0)},
      {'label': 'Badges Earned', 'value': '$badges / 6', 'icon': Icons.military_tech, 'color': AppTheme.gold},
      {'label': 'Current Rank', 'value': rank, 'icon': Icons.emoji_events, 'color': AppTheme.bronze},
      {'label': 'Day Streak', 'value': '$streak 🔥', 'icon': Icons.local_fire_department, 'color': Colors.orange},
      {'label': 'XP to Max Rank', 'value': '${1000 - xp} XP', 'icon': Icons.trending_up, 'color': AppTheme.correct},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progress Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
          const SizedBox(height: 4),
          const Text('Your full stats at a glance',
              style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
          const SizedBox(height: 16),
          ...rows.map((row) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: (row['color'] as Color).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(row['icon'] as IconData, color: row['color'] as Color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(row['label'] as String,
                      style: const TextStyle(fontSize: 14, color: AppTheme.darkGrey)),
                ),
                Text(row['value'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: row['color'] as Color,
                    )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

