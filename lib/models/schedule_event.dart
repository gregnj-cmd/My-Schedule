class ScheduleEvent {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String category;
  final int priority;
  final bool isCompleted;
  final String notes;
  final List<Map<String, dynamic>> subTasks; // { 'title': String, 'isDone': bool }
  final bool hasConflict;

  ScheduleEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    this.category = 'Personal',
    this.priority = 1,
    this.isCompleted = false,
    this.notes = '',
    this.subTasks = const [],
    this.hasConflict = false,
  });

  ScheduleEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? category,
    int? priority,
    bool? isCompleted,
    String? notes,
    List<Map<String, dynamic>>? subTasks,
    bool? hasConflict,
  }) {
    return ScheduleEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
      subTasks: subTasks ?? this.subTasks,
      hasConflict: hasConflict ?? this.hasConflict,
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
      'notes': notes,
      'subTasks': subTasks,
      'hasConflict': hasConflict,
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
      notes: map['notes'] ?? '',
      subTasks: List<Map<String, dynamic>>.from(map['subTasks'] ?? []),
      hasConflict: map['hasConflict'] ?? false,
    );
  }
}
