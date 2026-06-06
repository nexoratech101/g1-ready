import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../data/question_data.dart';
import '../models/question.dart';
import '../screens/learn_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Question> _savedQuestions = [];
  List<LearnTopic> _savedTopics = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadQuestions(), _loadTopics()]);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadQuestions() async {
    final ids = await StorageService.getBookmarks();
    final all = [
      ...QuestionData.set1, ...QuestionData.set2,
      ...QuestionData.set3, ...QuestionData.set4,
      ...QuestionData.set5, ...QuestionData.set6,
      ...QuestionData.set7, ...QuestionData.set8,
    ];
    _savedQuestions = all.where((q) => ids.contains(q.id)).toList();
  }

  Future<void> _loadTopics() async {
    final ids = await StorageService.getBookmarks();
    _savedTopics = LearnData.topics.where((t) => ids.contains(t.id)).toList();
  }

  Future<void> _removeQuestion(String id) async {
    await StorageService.toggleBookmark(id);
    await _loadQuestions();
    setState(() {});
  }

  Future<void> _removeTopic(String id) async {
    await StorageService.toggleBookmark(id);
    await _loadTopics();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Saved'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.white,
          labelColor: AppTheme.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'Questions (${_savedQuestions.length})'),
            Tab(text: 'Lessons (${_savedTopics.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.canadianRed))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildQuestionsTab(),
                _buildTopicsTab(),
              ],
            ),
    );
  }

  Widget _buildQuestionsTab() {
    if (_savedQuestions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.quiz,
        title: 'No saved questions',
        subtitle: 'Tap the bookmark icon on any\nquestion to save it here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedQuestions.length,
      itemBuilder: (context, index) {
        final q = _savedQuestions[index];
        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.canadianRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(q.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.canadianRed,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: AppTheme.canadianRed, size: 20),
                    onPressed: () => _removeQuestion(q.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(q.question,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGrey,
                  )),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.correct.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.correct, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(q.options[q.correctIndex],
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.correct,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(q.explanation,
                  style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopicsTab() {
    if (_savedTopics.isEmpty) {
      return _buildEmptyState(
        icon: Icons.menu_book,
        title: 'No saved lessons',
        subtitle: 'Tap the bookmark icon on any\nlesson to save it here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _savedTopics.length,
      itemBuilder: (context, index) {
        final t = _savedTopics[index];
        final color = t.level == 1
            ? AppTheme.canadianRed
            : t.level == 2
                ? AppTheme.warning
                : AppTheme.correct;
        final levelLabel = t.level == 1
            ? 'Core'
            : t.level == 2
                ? 'Important'
                : 'Unusual';

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TopicDetailScreen(topic: t),
            ),
          ).then((_) => _loadAll().then((_) => setState(() {}))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(levelLabel,
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          )),
                      Row(
                        children: [
                          Text(t.category,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              )),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeTopic(t.id),
                            child: const Icon(Icons.bookmark, color: AppTheme.white, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppTheme.darkGrey,
                                )),
                            const SizedBox(height: 4),
                            Text(t.summary,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.mediumGrey,
                                )),
                            const SizedBox(height: 6),
                            Text('${t.keyPoints.length} key points',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: color),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: AppTheme.mediumGrey),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              )),
          const SizedBox(height: 8),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.mediumGrey)),
        ],
      ),
    );
  }
}
