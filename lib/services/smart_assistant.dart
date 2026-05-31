import '../models/schedule_event.dart';

class SmartAssistant {
  static Map<String, dynamic> analyzeTitle(String title) {
    final lowerTitle = title.toLowerCase();
    
    // Default values
    String category = 'Personal';
    int priority = 1;

    // Keyword analysis for Work
    if (lowerTitle.contains('meeting') || 
        lowerTitle.contains('work') || 
        lowerTitle.contains('presentation') ||
        lowerTitle.contains('deadline') ||
        lowerTitle.contains('call')) {
      category = 'Work';
      priority = 2;
    }

    // Keyword analysis for Fitness
    if (lowerTitle.contains('gym') || 
        lowerTitle.contains('workout') || 
        lowerTitle.contains('run') ||
        lowerTitle.contains('training') ||
        lowerTitle.contains('sport')) {
      category = 'Fitness';
      priority = 1;
    }

    // Urgent keywords
    if (lowerTitle.contains('urgent') || 
        lowerTitle.contains('asap') || 
        lowerTitle.contains('important') ||
        lowerTitle.contains('emergency')) {
      priority = 3;
    }

    return {
      'category': category,
      'priority': priority,
    };
  }

  static String getDailyInsight(List<ScheduleEvent> events) {
    if (events.isEmpty) {
      return "Your schedule is clear! It's a great day to start a new project or relax.";
    }

    final highPriority = events.where((e) => e.priority == 3 && !e.isCompleted).length;
    final totalPending = events.where((e) => !e.isCompleted).length;

    if (highPriority > 2) {
      return "You have a heavy workload today with $highPriority high-priority tasks. Focus on those first!";
    }

    if (totalPending > 5) {
      return "You have $totalPending tasks today. Try to break them down and take regular breaks.";
    }

    return "Looking good! You have a balanced schedule today. Stay productive!";
  }
}
