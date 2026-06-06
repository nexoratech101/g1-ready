import '../models/question.dart';

class QuestionData {
  static const List<Question> set1 = [
    Question(
      id: '1_1',
      question: 'What does a red octagon sign mean?',
      options: ['Slow down', 'Stop completely', 'Yield to traffic', 'No entry'],
      correctIndex: 1,
      explanation: 'A red octagon is a STOP sign. You must come to a complete stop.',
      category: 'Road Signs',
    ),
    Question(
      id: '1_2',
      question: 'What does a yellow diamond sign indicate?',
      options: ['School zone', 'Warning or hazard ahead', 'Construction zone', 'Speed limit change'],
      correctIndex: 1,
      explanation: 'Yellow diamond signs warn drivers of upcoming hazards or changes in road conditions.',
      category: 'Road Signs',
    ),
    Question(
      id: '1_3',
      question: 'What does a white rectangular sign display?',
      options: ['Warnings', 'Regulatory information', 'Tourist attractions', 'Services ahead'],
      correctIndex: 1,
      explanation: 'White rectangular signs display regulatory information like speed limits and rules.',
      category: 'Road Signs',
    ),
    Question(
      id: '1_4',
      question: 'What shape is a yield sign?',
      options: ['Circle', 'Square', 'Inverted triangle', 'Pentagon'],
      correctIndex: 2,
      explanation: 'A yield sign is an inverted triangle. You must slow down and give way to traffic.',
      category: 'Road Signs',
    ),
    Question(
      id: '1_5',
      question: 'A green traffic light means?',
      options: ['Stop if safe', 'Proceed with caution', 'Go if the way is clear', 'Speed up'],
      correctIndex: 2,
      explanation: 'Green means go if the way is clear. Always check for crossing traffic first.',
      category: 'Road Signs',
    ),
  ];
}
