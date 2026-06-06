import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _xpKey = 'xp';
  static const _quizzesKey = 'quizzes_completed';
  static const _bookmarksKey = 'bookmarks';
  static const _scoresKey = 'scores';

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

  // Scores per set
  static Future<void> saveScore(String setId, int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_scoresKey}_$setId', '$score/$total');
  }

  static Future<String?> getScore(String setId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_scoresKey}_$setId');
  }

  // Bookmarks
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

  // Clear all
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
