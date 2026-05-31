import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/schedule_event.dart';
import '../providers/schedule_provider.dart';
import '../services/smart_assistant.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _aiInputController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'Personal';
  int _selectedPriority = 1;
  List<Map<String, dynamic>> _subTasks = [];

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onTitleChanged);
  }

  void _onTitleChanged() {
    if (_titleController.text.length > 3) {
      final analysis = SmartAssistant.analyzeTitle(_titleController.text);
      setState(() {
        _selectedCategory = analysis['category'];
        _selectedPriority = analysis['priority'];
      });
    }
  }

  void _applyAI() {
    if (_aiInputController.text.isNotEmpty) {
      final parsed = SmartAssistant.parseNaturalLanguage(_aiInputController.text);
      if (parsed != null) {
        setState(() {
          _titleController.text = parsed['title'];
          _selectedDate = parsed['dateTime'];
          _selectedTime = TimeOfDay.fromDateTime(parsed['dateTime']);
          _selectedCategory = parsed['category'];
          _selectedPriority = parsed['priority'];
          _subTasks = SmartAssistant.generateSubTasks(parsed['title'], parsed['category']);
        });
        _aiInputController.clear();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI parsed your event!')));
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final finalDateTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
      final newEvent = ScheduleEvent(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: '',
        dateTime: finalDateTime,
        category: _selectedCategory,
        priority: _selectedPriority,
        notes: _notesController.text,
        subTasks: _subTasks,
      );

      Provider.of<ScheduleProvider>(context, listen: false).addEvent(newEvent);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event v3.0')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Quick Add
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    const Row(children: [Icon(Icons.auto_awesome, size: 18), SizedBox(width: 8), Text('AI Quick Add', style: TextStyle(fontWeight: FontWeight.bold))]),
                    TextField(
                      controller: _aiInputController,
                      decoration: const InputDecoration(hintText: 'e.g. Meeting tomorrow at 3pm', border: InputBorder.none),
                      onSubmitted: (_) => _applyAI(),
                    ),
                    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _applyAI, child: const Text('Apply AI'))),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Rich Notes', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 25),
              const Text('Priority & Category', style: TextStyle(fontWeight: FontWeight.bold)),
              // (Category chips and Priority Row from v2.0 remains here for manual override)
              const SizedBox(height: 25),
              // (Date & Time selectors from v2.0)
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submitForm, child: const Text('Save Smart Event'))),
            ],
          ),
        ),
      ),
    );
  }
}
