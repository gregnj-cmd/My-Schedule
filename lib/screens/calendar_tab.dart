import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/schedule_provider.dart';
import '../models/schedule_event.dart';
import '../widgets/event_detail_modal.dart';
import 'add_event_screen.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEventScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              TableCalendar<ScheduleEvent>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(provider.selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  provider.setSelectedDate(selectedDay);
                  setState(() => _focusedDay = focusedDay);
                  if (provider.selectedDayEvents.isNotEmpty) {
                    _showDayEventsModal(context, provider);
                  }
                },
                onFormatChanged: (format) => setState(() => _calendarFormat = format),
                eventLoader: (day) => provider.events.where((e) => isSameDay(e.dateTime, day)).toList(),
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  markersMaxCount: 3,
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox();
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildCustomMarkers(events),
                    );
                  },
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text('Tap a day with dots to view details', style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomMarkers(List<ScheduleEvent> events) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: events.take(3).map((event) {
        Color dotColor = Colors.green;
        if (event.priority == 3) dotColor = Colors.red;
        if (event.priority == 2) dotColor = Colors.orange;
        if (event.hasConflict) dotColor = Colors.purple;
        
        return Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        );
      }).toList(),
    );
  }

  void _showDayEventsModal(BuildContext context, ScheduleProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventDetailModal(events: provider.selectedDayEvents),
    );
  }
}
