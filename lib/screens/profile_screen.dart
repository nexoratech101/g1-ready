import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _xp = 0;
  int _quizzes = 0;

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
    setState(() {
      _xp = xp;
      _quizzes = quizzes;
    });
  }

  String get _rankName {
    if (_xp >= 1000) return 'Expert';
    if (_xp >= 600) return 'Advanced';
    if (_xp >= 300) return 'Intermediate';
    if (_xp >= 100) return 'Learner';
    return 'Beginner';
  }

  int get _nextRankXP {
    if (_xp >= 1000) return 1000;
    if (_xp >= 600) return 1000;
    if (_xp >= 300) return 600;
    if (_xp >= 100) return 300;
    return 100;
  }

  int get _currentRankXP {
    if (_xp >= 1000) return 1000;
    if (_xp >= 600) return 600;
    if (_xp >= 300) return 300;
    if (_xp >= 100) return 100;
    return 0;
  }

  double get _rankProgress {
    if (_xp >= 1000) return 1.0;
    return (_xp - _currentRankXP) / (_nextRankXP - _currentRankXP);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 24),
              _buildXPCard(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildBadgesSection(),
              const SizedBox(height: 24),
              _buildRankSection(),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.white, width: 3),
            ),
            child: const Icon(Icons.person, size: 48, color: AppTheme.canadianRed),
          ),
          const SizedBox(height: 12),
          const Text(
            'G1 Student',
            style: TextStyle(
              color: AppTheme.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '🏆 $_rankName',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const Text(
                'Experience Points',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              Text(
                '$_xp / $_nextRankXP XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.canadianRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _rankProgress,
              minHeight: 12,
              backgroundColor: AppTheme.mediumGrey,
              valueColor: const AlwaysStoppedAnimation(AppTheme.canadianRed),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _xp >= 1000
                ? 'Maximum rank reached!'
                : 'Earn ${_nextRankXP - _xp} more XP to reach $_rankName!',
            style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('$_quizzes', 'Quizzes\nCompleted', Icons.quiz)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('$_xp XP', 'Total\nEarned', Icons.star)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(_rankName, 'Current\nRank', Icons.military_tech)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGrey, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.canadianRed, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {'icon': Icons.star, 'label': 'First Quiz', 'earned': _quizzes >= 1},
      {'icon': Icons.local_fire_department, 'label': '5 Quizzes', 'earned': _quizzes >= 5},
      {'icon': Icons.emoji_events, 'label': '100 XP', 'earned': _xp >= 100},
      {'icon': Icons.speed, 'label': '300 XP', 'earned': _xp >= 300},
      {'icon': Icons.school, 'label': '600 XP', 'earned': _xp >= 600},
      {'icon': Icons.military_tech, 'label': 'Expert', 'earned': _xp >= 1000},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Badges',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            final earned = badge['earned'] as bool;
            return Container(
              decoration: BoxDecoration(
                color: earned ? AppTheme.canadianRed : AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    badge['icon'] as IconData,
                    size: 32,
                    color: earned ? AppTheme.white : AppTheme.mediumGrey,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: earned ? AppTheme.white : AppTheme.mediumGrey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRankSection() {
    final ranks = [
      {'rank': 'Beginner', 'xp': '0 XP', 'color': AppTheme.mediumGrey, 'current': _rankName == 'Beginner'},
      {'rank': 'Learner', 'xp': '100 XP', 'color': AppTheme.bronze, 'current': _rankName == 'Learner'},
      {'rank': 'Intermediate', 'xp': '300 XP', 'color': AppTheme.silver, 'current': _rankName == 'Intermediate'},
      {'rank': 'Advanced', 'xp': '600 XP', 'color': AppTheme.gold, 'current': _rankName == 'Advanced'},
      {'rank': 'Expert', 'xp': '1000 XP', 'color': AppTheme.platinum, 'current': _rankName == 'Expert'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rank Ladder',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkGrey,
          ),
        ),
        const SizedBox(height: 12),
        ...ranks.map((rank) {
          final isCurrent = rank['current'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCurrent ? AppTheme.canadianRed : AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? AppTheme.canadianRed : AppTheme.lightGrey,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: rank['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events, color: AppTheme.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rank['rank'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isCurrent ? AppTheme.white : AppTheme.darkGrey,
                        ),
                      ),
                      Text(
                        rank['xp'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrent ? Colors.white70 : AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Current',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
