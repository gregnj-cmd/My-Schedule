class ScheduleEvent {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String category; // Work, Personal, Fitness, etc.
  final int priority; // 1: Low, 2: Medium, 3: High
  final bool isCompleted;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.category = 'Personal',
    this.priority = 1,
    this.isCompleted = false,
  });

  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? category,
    int? priority,
    bool? isCompleted,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory ScheduleEvent.fromMap(Map<String, dynamic> map) {
    return ScheduleEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      category: map['category'] ?? 'Personal',
      priority: map['priority'] ?? 1,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
