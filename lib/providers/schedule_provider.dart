import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule_event.dart';

class ScheduleProvider with ChangeNotifier {
  List<ScheduleEvent> _events = [];
  bool _isLoading = true;

  List<ScheduleEvent> get events => [..._events]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  bool get isLoading => _isLoading;

  ScheduleProvider() {
    loadEvents();
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
      }
    } catch (e) {
      debugPrint('Error loading events: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEvent(ScheduleEvent event) async {
    _events.add(event);
    await _saveEvents();
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    await _saveEvents();
    notifyListeners();
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
}
