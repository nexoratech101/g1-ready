import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/learning_mode_picker.dart';
import 'exam_screen.dart';
import 'settings_screen.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _xp = 0;
  int _quizzes = 0;
  int _streak = 0;
  int _badges = 0;
  String _learningModeId = 'exam_focus';

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
    final streak = await StorageService.updateStreak();
    final mode = await StorageService.getLearningMode();
    setState(() {
      _xp = xp;
      _quizzes = quizzes;
      _streak = streak;
      _badges = _calcBadges(xp, quizzes);
      _learningModeId = mode;
    });
  }

  int _calcBadges(int xp, int quizzes) {
    int count = 0;
    if (quizzes >= 1) count++;
    if (quizzes >= 5) count++;
    if (xp >= 100) count++;
    if (xp >= 300) count++;
    if (xp >= 600) count++;
    if (xp >= 1000) count++;
    return count;
  }

  String get _rank {
    if (_xp >= 1000) return 'Expert';
    if (_xp >= 600) return 'Advanced';
    if (_xp >= 300) return 'Intermediate';
    if (_xp >= 100) return 'Learner';
    return 'Beginner';
  }

  int get _currentRankXP {
    if (_xp >= 1000) return 1000;
    if (_xp >= 600) return 600;
    if (_xp >= 300) return 300;
    if (_xp >= 100) return 100;
    return 0;
  }

  int get _nextRankXP {
    if (_xp >= 1000) return 1000;
    if (_xp >= 600) return 1000;
    if (_xp >= 300) return 600;
    if (_xp >= 100) return 300;
    return 100;
  }

  double get _rankProgress {
    if (_xp >= 1000) return 1.0;
    return (_xp - _currentRankXP) / (_nextRankXP - _currentRankXP);
  }

  LearningMode get _mode => LearningModes.getById(_learningModeId);

  void _showRankLadder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _RankLadderSheet(currentXP: _xp, currentRank: _rank),
    );
  }

  void _showXPBreakdown() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _XPBreakdownSheet(
        xp: _xp, quizzes: _quizzes, badges: _badges,
        rank: _rank, nextRankXP: _nextRankXP, currentRankXP: _currentRankXP,
      ),
    );
  }

  String _getNextRankName() {
    if (_xp >= 1000) return 'Max Rank';
    if (_xp >= 600) return 'Expert';
    if (_xp >= 300) return 'Advanced';
    if (_xp >= 100) return 'Intermediate';
    return 'Learner';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: _mode.color,
        title: const Text('G1 Ready'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 2),
              Text('$_streak', style: const TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => _loadData()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 16),
              _buildRankProgressCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('What would you like to do?'),
              const SizedBox(height: 12),
              _buildActionCards(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _mode.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _mode.color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_mode.icon, color: AppTheme.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _mode.bannerMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Welcome Back! 👋',
              style: TextStyle(color: AppTheme.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Ready to ace your Ontario G1 test?',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 14),
          Row(children: [
            GestureDetector(
              onTap: _showRankLadder,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('🏆', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(_rank, style: const TextStyle(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: AppTheme.white, size: 16),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Text('⚡ $_xp XP',
                  style: const TextStyle(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildRankProgressCard() {
    final xpInCurrentRank = _xp - _currentRankXP;
    final xpNeededForRank = _nextRankXP - _currentRankXP;
    final xpRemaining = _nextRankXP - _xp;

    return GestureDetector(
      onTap: _showXPBreakdown,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rank Progress',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.darkGrey)),
                    Text('$_rank → ${_getNextRankName()}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                  ],
                ),
                const Row(children: [
                  Icon(Icons.touch_app, size: 14, color: AppTheme.mediumGrey),
                  SizedBox(width: 2),
                  Text('Details', style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                ]),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _rankProgress,
                minHeight: 12,
                backgroundColor: AppTheme.mediumGrey,
                valueColor: AlwaysStoppedAnimation(_mode.color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$xpInCurrentRank / $xpNeededForRank XP in this rank',
                    style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
                if (_xp < 1000)
                  Text('$xpRemaining XP to go',
                      style: TextStyle(fontSize: 11, color: _mode.color, fontWeight: FontWeight.w600)),
                if (_xp >= 1000)
                  const Text('Max rank! 🏆',
                      style: TextStyle(fontSize: 11, color: AppTheme.correct, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat('$_quizzes', 'Quizzes\nDone', Icons.quiz),
                _buildMiniStat('$_badges', 'Badges\nEarned', Icons.military_tech),
                _buildMiniStat(_rank, 'Current\nRank', Icons.emoji_events),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _mode.color, size: 18),
        const SizedBox(height: 4),
        Text(value, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
        Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppTheme.mediumGrey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey));
  }

  Widget _buildActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCard(
          context,
          icon: Icons.quiz,
          title: 'Practice\nTest',
          subtitle: 'Topic-based quizzes\n80 questions total',
          color: const Color(0xFF1565C0),
          onTap: () => MainScreen.of(context)?.switchTab(2),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildCard(
          context,
          icon: Icons.assignment,
          title: 'Exam\nSimulation',
          subtitle: '40 questions • 50 min\n80% to pass',
          color: AppTheme.darkGrey,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExamScreen()),
          ),
        )),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppTheme.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: AppTheme.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Start', style: TextStyle(color: AppTheme.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: AppTheme.white, size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rank Ladder Sheet ──────────────────────────────────────────────────────
class _RankLadderSheet extends StatelessWidget {
  final int currentXP;
  final String currentRank;
  const _RankLadderSheet({required this.currentXP, required this.currentRank});

  @override
  Widget build(BuildContext context) {
    final ranks = [
      {'rank': 'Beginner', 'xp': 0, 'color': AppTheme.mediumGrey, 'desc': 'Starting out'},
      {'rank': 'Learner', 'xp': 100, 'color': AppTheme.bronze, 'desc': 'Getting the hang of it'},
      {'rank': 'Intermediate', 'xp': 300, 'color': AppTheme.silver, 'desc': 'Building confidence'},
      {'rank': 'Advanced', 'xp': 600, 'color': AppTheme.gold, 'desc': 'Nearly exam ready'},
      {'rank': 'Expert', 'xp': 1000, 'color': AppTheme.platinum, 'desc': 'G1 Champion!'},
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rank Ladder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
              Text('$currentXP / 1000 XP', style: const TextStyle(fontSize: 14, color: AppTheme.canadianRed, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Earn XP by completing quizzes and exams', style: TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
          const SizedBox(height: 16),
          ...ranks.map((rank) {
            final isCurrent = rank['rank'] == currentRank;
            final rankXP = rank['xp'] as int;
            final isUnlocked = currentXP >= rankXP;
            final color = rank['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent ? AppTheme.canadianRed : AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isCurrent ? AppTheme.canadianRed : AppTheme.lightGrey, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: isUnlocked ? color : AppTheme.lightGrey, shape: BoxShape.circle),
                    child: Icon(Icons.emoji_events, color: isUnlocked ? AppTheme.white : AppTheme.mediumGrey, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rank['rank'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isCurrent ? AppTheme.white : AppTheme.darkGrey)),
                        Text('${rank['xp']} XP — ${rank['desc']}', style: TextStyle(fontSize: 11, color: isCurrent ? Colors.white70 : AppTheme.mediumGrey)),
                      ],
                    ),
                  ),
                  if (isCurrent) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: const Text('Current', style: TextStyle(color: AppTheme.white, fontSize: 12, fontWeight: FontWeight.w600))),
                  if (!isCurrent && isUnlocked) const Icon(Icons.check_circle, color: AppTheme.correct, size: 20),
                  if (!isUnlocked) const Icon(Icons.lock_outline, color: AppTheme.mediumGrey, size: 20),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── XP Breakdown Sheet ─────────────────────────────────────────────────────
class _XPBreakdownSheet extends StatelessWidget {
  final int xp, quizzes, badges, nextRankXP, currentRankXP;
  final String rank;
  const _XPBreakdownSheet({required this.xp, required this.quizzes, required this.badges, required this.rank, required this.nextRankXP, required this.currentRankXP});

  @override
  Widget build(BuildContext context) {
    final rows = [
      {'label': 'Total XP Earned', 'value': '$xp / 1000 XP', 'icon': Icons.star, 'color': AppTheme.canadianRed},
      {'label': 'Quizzes Completed', 'value': '$quizzes', 'icon': Icons.quiz, 'color': const Color(0xFF1565C0)},
      {'label': 'Badges Earned', 'value': '$badges / 6', 'icon': Icons.military_tech, 'color': AppTheme.gold},
      {'label': 'Current Rank', 'value': rank, 'icon': Icons.emoji_events, 'color': AppTheme.bronze},
      {'label': 'XP to Next Rank', 'value': '${nextRankXP - xp} XP', 'icon': Icons.trending_up, 'color': AppTheme.correct},
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progress Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
          const SizedBox(height: 16),
          ...rows.map((row) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: (row['color'] as Color).withOpacity(0.15), shape: BoxShape.circle), child: Icon(row['icon'] as IconData, color: row['color'] as Color, size: 18)),
                const SizedBox(width: 12),
                Expanded(child: Text(row['label'] as String, style: const TextStyle(fontSize: 14, color: AppTheme.darkGrey))),
                Text(row['value'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: row['color'] as Color)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
