class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
  });
}
