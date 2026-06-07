import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _xpKey = 'xp';
  static const _quizzesKey = 'quizzes_completed';
  static const _bookmarksKey = 'bookmarks';
  static const _topicBookmarksKey = 'topic_bookmarks';
  static const _scoresKey = 'scores';
  static const _streakKey = 'streak';
  static const _lastOpenKey = 'last_open';
  static const _totalQuestionsKey = 'total_questions';
  static const _learningModeKey = 'learning_mode';
  static const _pinnedSortKey = 'pinned_sort';
  static const _examDateKey = 'exam_date';

  // XP
  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_xpKey) ?? 0;
    await prefs.setInt(_xpKey, current + amount);
  }

  // Quizzes completed
  static Future<int> getQuizzesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quizzesKey) ?? 0;
  }

  static Future<void> incrementQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_quizzesKey) ?? 0;
    await prefs.setInt(_quizzesKey, current + 1);
  }

  // Total questions answered
  static Future<int> getTotalQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalQuestionsKey) ?? 0;
  }

  static Future<void> addQuestionsAnswered(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_totalQuestionsKey) ?? 0;
    await prefs.setInt(_totalQuestionsKey, current + count);
  }

  // Scores per set
  static Future<void> saveScore(String setId, int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_scoresKey}_$setId', '$score/$total');
  }

  static Future<String?> getScore(String setId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_scoresKey}_$setId');
  }

  static Future<Map<String, String>> getAllScores() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('${_scoresKey}_'));
    final result = <String, String>{};
    for (final key in keys) {
      final id = key.replaceFirst('${_scoresKey}_', '');
      result[id] = prefs.getString(key) ?? '';
    }
    return result;
  }

  // ── Question Bookmarks ────────────────────────────────────────
  static Future<List<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarksKey) ?? [];
  }

  static Future<void> toggleBookmark(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    if (bookmarks.contains(questionId)) {
      bookmarks.remove(questionId);
    } else {
      bookmarks.add(questionId);
    }
    await prefs.setStringList(_bookmarksKey, bookmarks);
  }

  static Future<bool> isBookmarked(String questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_bookmarksKey) ?? [];
    return bookmarks.contains(questionId);
  }

  // ── Topic Bookmarks (Learn section) ──────────────────────────
  static Future<List<String>> getTopicBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_topicBookmarksKey) ?? [];
  }

  static Future<void> toggleTopicBookmark(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_topicBookmarksKey) ?? [];
    if (bookmarks.contains(topicId)) {
      bookmarks.remove(topicId);
    } else {
      bookmarks.add(topicId);
    }
    await prefs.setStringList(_topicBookmarksKey, bookmarks);
  }

  static Future<bool> isTopicBookmarked(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_topicBookmarksKey) ?? [];
    return bookmarks.contains(topicId);
  }

  // ── Daily streak ──────────────────────────────────────────────
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  static Future<int> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpen = prefs.getString(_lastOpenKey);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (lastOpen == null) {
      await prefs.setString(_lastOpenKey, todayStr);
      await prefs.setInt(_streakKey, 1);
      return 1;
    }

    if (lastOpen == todayStr) {
      return prefs.getInt(_streakKey) ?? 1;
    }

    final last = DateTime.parse(lastOpen);
    final diff = today.difference(last).inDays;

    if (diff == 1) {
      final newStreak = (prefs.getInt(_streakKey) ?? 0) + 1;
      await prefs.setInt(_streakKey, newStreak);
      await prefs.setString(_lastOpenKey, todayStr);
      return newStreak;
    } else {
      await prefs.setInt(_streakKey, 1);
      await prefs.setString(_lastOpenKey, todayStr);
      return 1;
    }
  }

  // Pinned Sort
  static Future<String> getPinnedSort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinnedSortKey) ?? 'importance';
  }

  static Future<void> setPinnedSort(String sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinnedSortKey, sort);
  }

  // Exam Date
  static Future<DateTime?> getExamDate() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_examDateKey);
    return s != null ? DateTime.parse(s) : null;
  }

  static Future<void> setExamDate(DateTime? date) async {
    final prefs = await SharedPreferences.getInstance();
    if (date == null) {
      await prefs.remove(_examDateKey);
    } else {
      await prefs.setString(_examDateKey, date.toIso8601String());
    }
  }

  // Learning Mode
  static Future<String> getLearningMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_learningModeKey) ?? 'exam_focus';
  }

  static Future<void> setLearningMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_learningModeKey, mode);
  }

  // Clear all
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}


