import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('G1 Ready'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
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
              const SizedBox(height: 24),
              _buildSectionTitle('Your Progress'),
              const SizedBox(height: 12),
              _buildProgressCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Practice Tests'),
              const SizedBox(height: 12),
              _buildQuickStartGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('Exam Mode'),
              const SizedBox(height: 12),
              _buildExamModeCard(),
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
        color: AppTheme.canadianRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome Back!',
              style: TextStyle(color: AppTheme.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Ready to ace your G1 test?',
              style: TextStyle(color: AppTheme.white, fontSize: 14)),
          const SizedBox(height: 16),
          Row(children: [
            _buildStatChip('Beginner'),
            const SizedBox(width: 8),
            _buildStatChip('0 XP'),
          ]),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(color: AppTheme.white, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey));
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.lightGrey, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Readiness',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.darkGrey)),
              const Text('0%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.canadianRed)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0,
              minHeight: 10,
              backgroundColor: AppTheme.mediumGrey,
              valueColor: const AlwaysStoppedAnimation(AppTheme.canadianRed),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('0', 'Questions\nDone'),
              _buildMiniStat('0%', 'Accuracy'),
              _buildMiniStat('0', 'Badges'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.canadianRed)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
      ],
    );
  }

  Widget _buildQuickStartGrid() {
    final sets = [
      {'title': 'Set 1', 'topic': 'Road Signs'},
      {'title': 'Set 2', 'topic': 'Traffic Laws'},
      {'title': 'Set 3', 'topic': 'Right of Way'},
      {'title': 'Set 4', 'topic': 'Speed Limits'},
      {'title': 'Set 5', 'topic': 'Parking Rules'},
      {'title': 'Set 6', 'topic': 'Alcohol & Drugs'},
      {'title': 'Set 7', 'topic': 'Winter Driving'},
      {'title': 'Set 8', 'topic': 'Mixed Review'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: sets.length,
      itemBuilder: (context, index) => _buildSetCard(sets[index]),
    );
  }

  Widget _buildSetCard(Map<String, dynamic> set) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightGrey, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.quiz, color: AppTheme.canadianRed, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(set['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkGrey)),
              Text(set['topic'] as String,
                  style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExamModeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.darkGrey, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exam Simulation',
                    style: TextStyle(color: AppTheme.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('40 questions - 50 minutes\nPass mark: 80%',
                    style: TextStyle(color: AppTheme.mediumGrey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: AppTheme.canadianRed, borderRadius: BorderRadius.circular(10)),
            child: const Text('Start',
                style: TextStyle(color: AppTheme.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
