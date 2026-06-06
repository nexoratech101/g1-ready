import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../data/question_data.dart';
import '../models/question.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Question> _bookmarkedQuestions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final ids = await StorageService.getBookmarks();
    final all = [
      ...QuestionData.set1,
      ...QuestionData.set2,
      ...QuestionData.set3,
      ...QuestionData.set4,
      ...QuestionData.set5,
      ...QuestionData.set6,
      ...QuestionData.set7,
      ...QuestionData.set8,
    ];
    setState(() {
      _bookmarkedQuestions = all.where((q) => ids.contains(q.id)).toList();
      _loading = false;
    });
  }

  Future<void> _removeBookmark(String questionId) async {
    await StorageService.toggleBookmark(questionId);
    _loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          if (_bookmarkedQuestions.isNotEmpty)
            TextButton(
              onPressed: () async {
                await StorageService.clearAll();
                _loadBookmarks();
              },
              child: const Text('Clear All',
                  style: TextStyle(color: AppTheme.white)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.canadianRed))
          : _bookmarkedQuestions.isEmpty
              ? _buildEmptyState()
              : _buildBookmarksList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: AppTheme.mediumGrey),
          SizedBox(height: 16),
          Text(
            'No bookmarks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap the bookmark icon during\na quiz to save questions here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _bookmarkedQuestions.length,
      itemBuilder: (context, index) {
        final q = _bookmarkedQuestions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                    child: Text(
                      q.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.canadianRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: AppTheme.canadianRed, size: 20),
                    onPressed: () => _removeBookmark(q.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                q.question,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkGrey,
                ),
              ),
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
                      child: Text(
                        q.options[q.correctIndex],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.correct,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                q.explanation,
                style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey),
              ),
            ],
          ),
        );
      },
    );
  }
}
