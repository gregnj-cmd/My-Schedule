import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_event.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleEvent> _events = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  List<ScheduleEvent> get events => [..._events]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  List<ScheduleEvent> get selectedDayEvents {
    return _events.where((event) {
      return event.dateTime.year == _selectedDate.year &&
             event.dateTime.month == _selectedDate.month &&
             event.dateTime.day == _selectedDate.day;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  ScheduleProvider() {
    loadEvents();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? eventsJson = prefs.getString('scheduled_events');
      if (eventsJson != null) {
        final List<dynamic> decoded = json.decode(eventsJson);
        _events = decoded.map((item) => ScheduleEvent.fromMap(item)).toList();
        _checkAllConflicts();
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent(ScheduleEvent event) async {
    _events.add(event);
    _checkAllConflicts();
    await _saveEvents();
    notifyListeners();
  }

  Future<void> updateEvent(ScheduleEvent event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      _checkAllConflicts();
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id) async {
    final index = _events.indexWhere((e) => e.id == id);
    if (index != -1) {
      _events[index] = _events[index].copyWith(isCompleted: !_events[index].isCompleted);
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> toggleSubTask(String eventId, int subTaskIndex) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final updatedSubTasks = List<Map<String, dynamic>>.from(_events[index].subTasks);
      updatedSubTasks[subTaskIndex]['isDone'] = !updatedSubTasks[subTaskIndex]['isDone'];
      _events[index] = _events[index].copyWith(subTasks: updatedSubTasks);
      await _saveEvents();
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    _checkAllConflicts();
    await _saveEvents();
    notifyListeners();
  }

  void _checkAllConflicts() {
    for (int i = 0; i < _events.length; i++) {
      bool hasConflict = false;
      for (int j = 0; j < _events.length; j++) {
        if (i == j) continue;
        
        final e1 = _events[i];
        final e2 = _events[j];
        
        // Check if events are within 1 hour of each other
        final difference = e1.dateTime.difference(e2.dateTime).inMinutes.abs();
        if (difference < 60) {
          hasConflict = true;
          break;
        }
      }
      _events[i] = _events[i].copyWith(hasConflict: hasConflict);
    }
  }

  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_events.map((e) => e.toMap()).toList());
      await prefs.setString('scheduled_events', encoded);
    } catch (e) {
      debugPrint('Error saving events: $e');
    }
  }

  // Analytics
  double get completionRate {
    if (_events.isEmpty) return 0.0;
    final completed = _events.where((e) => e.isCompleted).length;
    return completed / _events.length;
  }

  int get highPriorityCount {
    return _events.where((e) => e.priority == 3 && !e.isCompleted).length;
  }

  int get conflictCount {
    return _events.where((e) => e.hasConflict && !e.isCompleted).length;
  }
}
