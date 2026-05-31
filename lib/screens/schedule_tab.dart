import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../widgets/event_card.dart';
import 'add_event_screen.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        centerTitle: true,
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.events.isEmpty) {
            return const Center(
              child: Text(
                'No events scheduled yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Group events by day for a better list view
          final Map<String, List> groupedEvents = {};
          for (var event in provider.events) {
            final dateStr = DateFormat('EEEE, MMM dd').format(event.dateTime);
            if (groupedEvents[dateStr] == null) groupedEvents[dateStr] = [];
            groupedEvents[dateStr]!.add(event);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: groupedEvents.length,
            itemBuilder: (context, index) {
              final dateStr = groupedEvents.keys.elementAt(index);
              final events = groupedEvents[dateStr]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: Text(
                      dateStr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  ...events.map((event) => EventCard(event: event)),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEventScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
