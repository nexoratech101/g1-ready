import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/question_data.dart';
import '../services/storage_service.dart';
import 'quiz_screen.dart';
import 'exam_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _xp = 0;
  int _quizzes = 0;
  String _rank = 'Beginner';

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
      _rank = _getRank(xp);
    });
  }

  String _getRank(int xp) {
    if (xp >= 1000) return 'Expert';
    if (xp >= 600) return 'Advanced';
    if (xp >= 300) return 'Intermediate';
    if (xp >= 100) return 'Learner';
    return 'Beginner';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('G1 Ready'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
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
              _buildQuickStartGrid(context),
              const SizedBox(height: 24),
              _buildSectionTitle('Exam Mode'),
              const SizedBox(height: 12),
              _buildExamModeCard(context),
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
            _buildStatChip('🏆 $_rank'),
            const SizedBox(width: 8),
            _buildStatChip('⚡ $_xp XP'),
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
    double progress = _quizzes / 8;
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
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.canadianRed)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppTheme.mediumGrey,
              valueColor: const AlwaysStoppedAnimation(AppTheme.canadianRed),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('$_quizzes', 'Quizzes\nDone'),
              _buildMiniStat('$_xp XP', 'Total\nEarned'),
              _buildMiniStat(_rank, 'Current\nRank'),
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
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.canadianRed)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.mediumGrey)),
      ],
    );
  }

  Widget _buildQuickStartGrid(BuildContext context) {
    final sets = [
      {'title': 'Set 1', 'topic': 'Road Signs',      'id': 'set1', 'questions': QuestionData.set1},
      {'title': 'Set 2', 'topic': 'Traffic Laws',    'id': 'set2', 'questions': QuestionData.set2},
      {'title': 'Set 3', 'topic': 'Right of Way',    'id': 'set3', 'questions': QuestionData.set3},
      {'title': 'Set 4', 'topic': 'Speed Limits',    'id': 'set4', 'questions': QuestionData.set4},
      {'title': 'Set 5', 'topic': 'Parking Rules',   'id': 'set5', 'questions': QuestionData.set5},
      {'title': 'Set 6', 'topic': 'Alcohol & Drugs', 'id': 'set6', 'questions': QuestionData.set6},
      {'title': 'Set 7', 'topic': 'Winter Driving',  'id': 'set7', 'questions': QuestionData.set7},
      {'title': 'Set 8', 'topic': 'Mixed Review',    'id': 'set8', 'questions': QuestionData.set8},
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
      itemBuilder: (context, index) => _buildSetCard(context, sets[index]),
    );
  }

  Widget _buildSetCard(BuildContext context, Map<String, dynamic> set) {
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
        _loadData();
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildExamModeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExamScreen()),
      ),
      child: Container(
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
      ),
    );
  }
}
