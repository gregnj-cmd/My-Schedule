import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/schedule_event.dart';
import '../providers/schedule_provider.dart';

class EventDetailModal extends StatelessWidget {
  final List<ScheduleEvent> events;

  const EventDetailModal({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                DateFormat('EEEE, MMM dd').format(events.first.dateTime),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildImmersiveEventTile(context, event);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImmersiveEventTile(BuildContext context, ScheduleEvent event) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: event.hasConflict ? Border.all(color: Colors.redAccent, width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Theme.of(context).primaryColor),
              const SizedBox(width: 5),
              Text(DateFormat('hh:mm a').format(event.dateTime), style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (event.hasConflict)
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (event.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(event.notes, style: const TextStyle(color: Colors.grey)),
          ],
          if (event.subTasks.isNotEmpty) ...[
            const SizedBox(height: 15),
            const Text('Checklist', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ...event.subTasks.asMap().entries.map((entry) {
              return Row(
                children: [
                  Checkbox(
                    value: entry.value['isDone'],
                    onChanged: (val) {
                      Provider.of<ScheduleProvider>(context, listen: false).toggleSubTask(event.id, entry.key);
                    },
                  ),
                  Text(
                    entry.value['title'],
                    style: TextStyle(decoration: entry.value['isDone'] ? TextDecoration.lineThrough : null),
                  ),
                ],
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
