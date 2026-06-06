import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class LearningMode {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String bannerMessage;

  const LearningMode({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.bannerMessage,
  });
}

class LearningModes {
  static const List<LearningMode> all = [
    LearningMode(
      id: 'exam_focus',
      title: 'Exam Focus',
      description: 'Prioritize the most tested questions. Best for exam day preparation.',
      icon: Icons.military_tech,
      color: AppTheme.canadianRed,
      bannerMessage: 'Focus mode — let\'s ace that exam! 🎯',
    ),
    LearningMode(
      id: 'full_study',
      title: 'Full Study',
      description: 'Cover all topics systematically. Best for thorough preparation.',
      icon: Icons.menu_book,
      color: Color(0xFF1565C0),
      bannerMessage: 'Full study mode — building your knowledge! 📚',
    ),
    LearningMode(
      id: 'quick_prep',
      title: 'Quick Prep',
      description: 'Short focused sessions. Perfect for busy schedules.',
      icon: Icons.bolt,
      color: Color(0xFF2E7D32),
      bannerMessage: 'Quick prep mode — fast and efficient! ⚡',
    ),
    LearningMode(
      id: 'weak_areas',
      title: 'Weak Areas',
      description: 'Focus on your worst performing topics. Best for improvement.',
      icon: Icons.trending_up,
      color: Color(0xFFE65100),
      bannerMessage: 'Improvement mode — targeting your weak spots! 🔄',
    ),
  ];

  static LearningMode getById(String id) {
    return all.firstWhere((m) => m.id == id, orElse: () => all[0]);
  }
}

class LearningModePicker extends StatefulWidget {
  final String selectedId;
  final Function(String) onSelected;
  final bool showTitle;

  const LearningModePicker({
    super.key,
    required this.selectedId,
    required this.onSelected,
    this.showTitle = true,
  });

  @override
  State<LearningModePicker> createState() => _LearningModePickerState();
}

class _LearningModePickerState extends State<LearningModePicker> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedId;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle) ...[
          const Text('Learning Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
          const SizedBox(height: 4),
          const Text('Choose how you want to study',
              style: TextStyle(fontSize: 13, color: AppTheme.mediumGrey)),
          const SizedBox(height: 16),
        ],
        ...LearningModes.all.map((mode) {
          final isSelected = _selected == mode.id;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = mode.id);
              widget.onSelected(mode.id);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? mode.color : AppTheme.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? mode.color : AppTheme.lightGrey,
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? mode.color.withOpacity(0.2) : Colors.black.withOpacity(0.04),
                    blurRadius: isSelected ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white24 : mode.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(mode.icon,
                        color: isSelected ? AppTheme.white : mode.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mode.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isSelected ? AppTheme.white : AppTheme.darkGrey,
                            )),
                        const SizedBox(height: 3),
                        Text(mode.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : AppTheme.mediumGrey,
                              height: 1.3,
                            )),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppTheme.white, size: 22),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
