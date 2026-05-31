import '../models/schedule_event.dart';

class SmartAssistant {
  static Map<String, dynamic> analyzeTitle(String title) {
    final lowerTitle = title.toLowerCase();
    String category = 'Personal';
    int priority = 1;

    if (lowerTitle.contains('meeting') || lowerTitle.contains('work') || lowerTitle.contains('call')) {
      category = 'Work';
      priority = 2;
    } else if (lowerTitle.contains('gym') || lowerTitle.contains('workout') || lowerTitle.contains('run')) {
      category = 'Fitness';
    } else if (lowerTitle.contains('dinner') || lowerTitle.contains('party') || lowerTitle.contains('lunch')) {
      category = 'Social';
    }

    if (lowerTitle.contains('urgent') || lowerTitle.contains('important') || lowerTitle.contains('asap')) {
      priority = 3;
    }

    return {'category': category, 'priority': priority};
  }

  static List<Map<String, dynamic>> generateSubTasks(String title, String category) {
    final lowerTitle = title.toLowerCase();
    List<Map<String, dynamic>> subTasks = [];

    if (category == 'Work' || lowerTitle.contains('meeting')) {
      subTasks = [
        {'title': 'Prepare agenda', 'isDone': false},
        {'title': 'Review background docs', 'isDone': false},
        {'title': 'Send follow-up notes', 'isDone': false},
      ];
    } else if (category == 'Fitness' || lowerTitle.contains('gym')) {
      subTasks = [
        {'title': 'Pack gear', 'isDone': false},
        {'title': 'Hydrate', 'isDone': false},
        {'title': 'Post-workout stretch', 'isDone': false},
      ];
    } else if (lowerTitle.contains('travel') || lowerTitle.contains('trip')) {
      subTasks = [
        {'title': 'Check tickets', 'isDone': false},
        {'title': 'Pack essentials', 'isDone': false},
      ];
    }

    return subTasks;
  }

  static Map<String, dynamic>? parseNaturalLanguage(String text) {
    final lowerText = text.toLowerCase();
    
    // Basic NLP extraction using Regex
    DateTime targetDate = DateTime.now();
    
    // Date parsing
    if (lowerText.contains('tomorrow')) {
      targetDate = DateTime.now().add(const Duration(days: 1));
    } else if (lowerText.contains('today')) {
      targetDate = DateTime.now();
    } else if (lowerText.contains('next monday')) {
      int daysUntilMonday = (DateTime.monday - DateTime.now().weekday + 7) % 7;
      if (daysUntilMonday == 0) daysUntilMonday = 7;
      targetDate = DateTime.now().add(Duration(days: daysUntilMonday));
    }

    // Time parsing (e.g., 3pm, 14:00, at 5)
    int hour = 9; // Default 9 AM
    final timeMatch = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)?').firstMatch(lowerText);
    if (timeMatch != null) {
      hour = int.parse(timeMatch.group(1)!);
      final amPm = timeMatch.group(3);
      if (amPm == 'pm' && hour < 12) hour += 12;
      if (amPm == 'am' && hour == 12) hour = 0;
    }

    final finalDateTime = DateTime(targetDate.year, targetDate.month, targetDate.day, hour);

    // Title extraction (simple: everything before time/date keywords)
    String title = text.split(RegExp(r'(at|on|tomorrow|today|next)')).first.trim();
    if (title.isEmpty) title = "New Event";

    final analysis = analyzeTitle(title);

    return {
      'title': title,
      'dateTime': finalDateTime,
      'category': analysis['category'],
      'priority': analysis['priority'],
    };
  }

  static String getDailyInsight(List<ScheduleEvent> events) {
    if (events.isEmpty) return "Your schedule is wide open. A perfect day for creativity!";

    final pending = events.where((e) => !e.isCompleted).toList();
    final highPriority = pending.where((e) => e.priority == 3).length;
    final conflicts = pending.where((e) => e.hasConflict).length;

    if (conflicts > 0) {
      return "Alert: You have $conflicts scheduling conflicts. I recommend checking your calendar immediately.";
    }

    if (highPriority > 2) {
      return "You have $highPriority critical tasks today. I've highlighted them for you.";
    }

    if (pending.length > 5) {
      return "It's a busy one! You have ${pending.length} tasks. Remember to take short breaks every 90 minutes.";
    }

    return "Your schedule looks balanced and manageable. You've got this!";
  }
}
