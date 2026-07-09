import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../data/daily_facts.dart';

class NotificationService {
  static const _dailyTipHour = 9;
  static const _dailyTipMinute = 0;
  static const _upcomingDays = 14;
  static const _baseId = 5000;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTimeZone.identifier));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? false;
  }

  static Future<bool> isEnabled() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.areNotificationsEnabled() ?? false;
  }

  /// Schedules the next [_upcomingDays] days of daily driving-tip
  /// notifications, cycling through DailyFacts the same way the
  /// in-app "Did You Know?" splash dialog does.
  static Future<void> scheduleUpcomingTips() async {
    await initialize();
    if (!await isEnabled()) return;

    for (var i = 0; i < _upcomingDays; i++) {
      await _plugin.cancel(_baseId + i);
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_tip_channel',
      'Daily Driving Tips',
      channelDescription: 'A daily fun fact to help you pass your G1 test',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < _upcomingDays; i++) {
      final date = now.add(Duration(days: i));
      final scheduled = tz.TZDateTime(
        tz.local, date.year, date.month, date.day, _dailyTipHour, _dailyTipMinute,
      );
      if (scheduled.isBefore(now)) continue;

      final fact = DailyFacts.facts[date.day % DailyFacts.facts.length];
      await _plugin.zonedSchedule(
        _baseId + i,
        '🍁 Daily Driving Tip',
        '$fact Open G1 Ready to learn more!',
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
