import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class LearnTopic {
  final String id;
  final String title;
  final String summary;
  final int level;
  final String category;
  final List<String> keyPoints;
  const LearnTopic({required this.id, required this.title, required this.summary, required this.level, required this.category, required this.keyPoints});
}

class LearnData {
  static const List<LearnTopic> topics = [
    LearnTopic(id: 'l1_speed', title: 'Speed Limits in Ontario', summary: 'Know the exact speed limits for every zone type.', level: 1, category: 'Speed & Space', keyPoints: ['Urban roads: 50 km/h unless posted', 'Highways: 100 km/h unless posted', 'School zones: 40 km/h when children present', 'Community safety zones: posted limit fines doubled', 'Construction zones: posted limit fines doubled', 'County roads: 80 km/h unless posted']),
    LearnTopic(id: 'l1_bac', title: 'Blood Alcohol & Zero Tolerance', summary: 'BAC rules differ for G1/G2 vs fully licensed drivers.', level: 1, category: 'Alcohol & Drugs', keyPoints: ['G1 and G2 drivers: ZERO alcohol — any amount is illegal', 'Fully licensed drivers: legal limit is 0.08', 'Warn range: 0.05 to 0.07 — immediate licence suspension', 'Cannabis impairs driving — same laws apply', 'Prescription drugs can also impair — check labels', 'Only time reduces BAC — not coffee or water']),
    LearnTopic(id: 'l1_signs', title: 'Road Sign Shapes and Colors', summary: 'Each sign shape and color has a specific meaning.', level: 1, category: 'Road Signs', keyPoints: ['Red octagon = STOP — come to a complete stop', 'Inverted triangle = YIELD — slow and give way', 'Yellow diamond = WARNING — hazard ahead', 'White rectangle = REGULATORY — rules and limits', 'Green = information and directions', 'Orange = construction or maintenance zone', 'Blue = services such as gas food hospital', 'Pennant shape = NO PASSING ZONE']),
    LearnTopic(id: 'l1_row', title: 'Right of Way Rules', summary: 'Who goes first — the most tested topic on G1.', level: 1, category: 'Traffic Control', keyPoints: ['Four-way stop: first to arrive goes first', 'Tie at four-way stop: yield to vehicle on your right', 'Turning left: yield to all oncoming traffic', 'Merging onto highway: yield to vehicles already on it', 'Uncontrolled intersection: yield to vehicle on your right', 'Pedestrians in crosswalk: always have right of way', 'Blind pedestrian with white cane: absolute right of way']),
    LearnTopic(id: 'l1_follow', title: 'Following Distance and Stopping', summary: 'The 3-second rule and how weather changes everything.', level: 1, category: 'Speed & Space', keyPoints: ['Ideal conditions: minimum 3-second following distance', 'Rain or fog: increase to 4 to 5 seconds', 'Snow or ice: increase to 6 or more seconds', 'Doubling speed quadruples stopping distance', 'Look ahead for brake lights and hazards early', 'Never tailgate — it is aggressive driving']),
    LearnTopic(id: 'l1_seatbelt', title: 'Seatbelts and Child Safety', summary: 'Seatbelts are mandatory for all occupants in Ontario.', level: 1, category: 'Traffic Laws', keyPoints: ['All occupants must wear seatbelts at all times', 'Driver is responsible for passengers under 16', 'Children under 18 kg must use rear-facing car seat', 'Children 18 to 36 kg must use forward-facing car seat', 'Children up to 36 kg should use booster seat', 'Fines apply to both driver and unbelted passenger']),
    LearnTopic(id: 'l1_lights', title: 'Traffic Lights and Signals', summary: 'Every light colour and variation tested on the G1.', level: 1, category: 'Traffic Control', keyPoints: ['Green light: go if the way is clear', 'Yellow light: slow down and stop if safe', 'Red light: stop completely before the stop line', 'Flashing red: treat as a STOP sign', 'Flashing yellow: slow down and proceed with caution', 'Green arrow: proceed only in arrow direction', 'Right turn on red: allowed after full stop and yield']),
    LearnTopic(id: 'l1_schoolbus', title: 'School Bus Laws', summary: 'One of the most frequently tested topics on the G1.', level: 1, category: 'Vulnerable Road Users', keyPoints: ['Flashing red lights: STOP in both directions', 'Exception: divided highway with raised median', 'Must stop at least 20 metres from the bus', 'Do not move until lights stop and bus moves', 'Flashing amber lights: bus about to stop — slow down', 'Penalty: heavy fine and 6 demerit points']),
    LearnTopic(id: 'l2_parking', title: 'Parking Rules and Restrictions', summary: 'Where you can and cannot park in Ontario.', level: 2, category: 'Parking', keyPoints: ['No parking within 3 metres of a fire hydrant', 'No parking within 9 metres of an intersection', 'No parking within 9 metres of a crosswalk', 'Never park in front of a driveway', 'No parking on a bridge', 'Uphill with curb: wheels away from curb', 'Downhill: wheels toward the curb']),
    LearnTopic(id: 'l2_cyclists', title: 'Cyclists and Pedestrians', summary: 'Sharing the road with vulnerable road users.', level: 2, category: 'Vulnerable Road Users', keyPoints: ['Give cyclists at least 1 metre of space when passing', 'Check for cyclists before opening car door', 'Pedestrians at crosswalks always have right of way', 'Yield to pedestrians when turning at intersections', 'Watch for pedestrians at unmarked crosswalks too']),
    LearnTopic(id: 'l2_lanes', title: 'Lane Changing and Merging', summary: 'Safe lane changes require more than just a mirror check.', level: 2, category: 'Highway', keyPoints: ['Signal at least 30 metres before changing lanes', 'Check mirrors AND blind spot before every lane change', 'Never change multiple lanes at once', 'Merging onto highway: match highway speed first', 'HOV lanes: require 2 or more occupants during posted hours', 'Keep right except when passing on highways']),
    LearnTopic(id: 'l2_roundabout', title: 'Roundabouts', summary: 'Roundabouts require specific right of way rules.', level: 2, category: 'Traffic Control', keyPoints: ['Vehicles already in roundabout have right of way', 'Yield to traffic from your left when entering', 'Travel counter-clockwise around the centre island', 'Do not stop inside a roundabout', 'Signal when exiting the roundabout']),
    LearnTopic(id: 'l3_farm', title: 'Farm Equipment and Slow Vehicles', summary: 'Rarely tested but good to know for rural roads.', level: 3, category: 'Special Conditions', keyPoints: ['Slow Moving Vehicle sign = orange triangle on back', 'These vehicles travel under 40 km/h', 'Pass only when safe with clear sight lines', 'Give extra space — they may be wider than they appear']),
    LearnTopic(id: 'l3_horses', title: 'Horses and Animals on Roads', summary: 'Edge case that occasionally appears on G1 exams.', level: 3, category: 'Special Conditions', keyPoints: ['Slow down and give wide berth to horses', 'Do not honk near horses — they may spook', 'Be prepared to stop completely if needed', 'Follow rider signals and instructions']),
  ];
}

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});
  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String _sortBy = 'importance';
  List<String> _savedIds = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final ids = await StorageService.getBookmarks();
    if (mounted) setState(() => _savedIds = ids);
  }

  final Map<int, Color> _levelColors = {
    1: AppTheme.canadianRed,
    2: AppTheme.warning,
    3: AppTheme.correct,
  };

  final Map<int, String> _levelLabels = {
    1: 'Core',
    2: 'Important',
    3: 'Unusual',
  };

  final Map<int, String> _levelTags = {
    1: 'Always on G1',
    2: 'Often on G1',
    3: 'Rarely on G1',
  };

  List<LearnTopic> get _sortedTopics {
    final list = List<LearnTopic>.from(LearnData.topics);
    switch (_sortBy) {
      case 'importance':
        list.sort((a, b) => a.level.compareTo(b.level));
        break;
      case 'az':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'category':
        list.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'keypoints':
        list.sort((a, b) => b.keyPoints.length.compareTo(a.keyPoints.length));
        break;
      case 'saved':
        list.sort((a, b) {
          final aSaved = _savedIds.contains(a.id) ? 0 : 1;
          final bSaved = _savedIds.contains(b.id) ? 0 : 1;
          return aSaved.compareTo(bSaved);
        });
        break;
    }
    return list;
  }

  String get _sortLabel {
    switch (_sortBy) {
      case 'importance': return 'Sorted by: Exam Importance';
      case 'az':         return 'Sorted by: A to Z';
      case 'category':   return 'Sorted by: Category';
      case 'keypoints':  return 'Sorted by: Most Key Points';
      case 'saved':      return 'Sorted by: Saved First';
      default:           return 'Sorted by: Exam Importance';
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = _sortedTopics;
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppTheme.white),
            onSelected: (v) {
              setState(() => _sortBy = v);
              if (v == 'saved') _loadSaved();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'importance', child: Text('By Exam Importance')),
              PopupMenuItem(value: 'category',   child: Text('By Category')),
              PopupMenuItem(value: 'az',         child: Text('A to Z')),
              PopupMenuItem(value: 'keypoints',  child: Text('Most Key Points First')),
              PopupMenuItem(value: 'saved',      child: Text('Saved Lessons First')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort, size: 14, color: AppTheme.mediumGrey),
                    const SizedBox(width: 6),
                    Text(_sortLabel,
                        style: const TextStyle(fontSize: 12, color: AppTheme.mediumGrey)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: topics.length,
                itemBuilder: (context, index) => _buildCard(context, topics[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, LearnTopic topic) {
    final color = _levelColors[topic.level]!;
    final tag = _levelTags[topic.level]!;
    final levelLabel = _levelLabels[topic.level]!;
    final isSaved = _savedIds.contains(topic.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: topic)),
      ).then((_) => _loadSaved()),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSaved ? color.withOpacity(0.5) : AppTheme.lightGrey,
            width: isSaved ? 2 : 1.5,
          ),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
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
                      if (isSaved)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.bookmark, color: AppTheme.white, size: 14),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topic.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.darkGrey,
                            )),
                        const SizedBox(height: 4),
                        Text(topic.category,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.mediumGrey,
                            )),
                        const SizedBox(height: 4),
                        Text('${topic.keyPoints.length} key points',
                            style: TextStyle(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.arrow_forward_ios, size: 12, color: color),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class TopicDetailScreen extends StatefulWidget {
  final LearnTopic topic;
  const TopicDetailScreen({super.key, required this.topic});
  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await StorageService.isBookmarked(widget.topic.id);
    if (mounted) setState(() => _saved = saved);
  }

  Future<void> _toggle() async {
    await StorageService.toggleBookmark(widget.topic.id);
    final saved = await StorageService.isBookmarked(widget.topic.id);
    if (mounted) {
      setState(() => _saved = saved);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_saved ? 'Saved for later!' : 'Removed from saved'),
        backgroundColor: _saved ? AppTheme.correct : AppTheme.mediumGrey,
        duration: const Duration(seconds: 1),
      ));
    }
  }

  Color get _c => widget.topic.level == 1
      ? AppTheme.canadianRed
      : widget.topic.level == 2
          ? AppTheme.warning
          : AppTheme.correct;

  String get _lbl => widget.topic.level == 1
      ? 'Core — Almost always on G1'
      : widget.topic.level == 2
          ? 'Important — Often on G1'
          : 'Extra — Rarely on G1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(widget.topic.title),
        actions: [
          IconButton(
            icon: Icon(
              _saved ? Icons.bookmark : Icons.bookmark_border,
              color: AppTheme.white,
            ),
            onPressed: _toggle,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _c.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _c.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: _c, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_lbl,
                          style: TextStyle(
                            color: _c,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(widget.topic.summary,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.darkGrey,
                    fontStyle: FontStyle.italic,
                  )),
              const SizedBox(height: 22),
              const Text('Key Points to Remember',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  )),
              const SizedBox(height: 12),
              ...widget.topic.keyPoints.asMap().entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.lightGrey),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  )],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(color: _c, shape: BoxShape.circle),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkGrey,
                            height: 1.4,
                          )),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _toggle,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _saved ? AppTheme.correct.withOpacity(0.1) : AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _saved ? AppTheme.correct : AppTheme.lightGrey,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _saved ? Icons.bookmark : Icons.bookmark_border,
                        color: _saved ? AppTheme.correct : AppTheme.mediumGrey,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _saved ? 'Saved for Later' : 'Save for Later',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _saved ? AppTheme.correct : AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




