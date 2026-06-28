import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/reminder_model.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});
  @override
  State<AddReminderScreen> createState() =>
      _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _titleCtrl = TextEditingController();
  bool _loading = false;
  String _date = '';
  String _time = '';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) =>
          Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) {
      setState(() {
        _date =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) =>
          Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) {
      setState(() {
        _time =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter a reminder title')));
      return;
    }
    setState(() => _loading = true);
    try {
      await DBService.insertReminder(ReminderModel(
        title: _titleCtrl.text.trim(),
        date: _date,
        time: _time,
      ));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('FinTrack Pro',
            style: TextStyle(color: Color(0xFF00BFA5))),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('ADD REMINDER',
                  style: TextStyle(
                      color: Color(0xFF00BFA5),
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            // Reminder title
            const Text('What do you want to be reminded of?',
                style: TextStyle(
                    color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'e.g. Pay electricity bill',
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 24),
            // Date picker
            const Text('Date',
                style: TextStyle(
                    color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.white38)),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _date.isEmpty ? 'DD/MM/YYYY' : _date,
                      style: TextStyle(
                          color: _date.isEmpty
                              ? Colors.white24
                              : Colors.white),
                    ),
                    const Icon(Icons.calendar_today,
                        color: Colors.white38, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Time picker
            const Text('Time',
                style: TextStyle(
                    color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.white38)),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _time.isEmpty ? 'HH:MM' : _time,
                      style: TextStyle(
                          color: _time.isEmpty
                              ? Colors.white24
                              : Colors.white),
                    ),
                    const Icon(Icons.access_time,
                        color: Colors.white38, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E8C),
        onPressed: _loading ? null : _save,
        child: _loading
            ? const CircularProgressIndicator(
                color: Colors.white)
            : const Icon(Icons.arrow_forward,
                color: Colors.white),
      ),
    );
  }
}