import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/reminder_model.dart';
import 'add_reminder_screen.dart';
import 'change_budget_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<ReminderModel> _reminders = [];
  double _budget = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await DBService.getReminders();
    final b = await DBService.getBudget();
    setState(() {
      _reminders = r;
      _budget = b;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await DBService.deleteReminder(id);
    _load();
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Home',
                style: TextStyle(color: Color(0xFF00BFA5))),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF00BFA5)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text('REMINDERS',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Budget info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Current Budget',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11)),
                            Text(
                              _budget == 0
                                  ? 'Not set'
                                  : '₹ ${_budget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ChangeBudgetScreen()))
                              .then((_) => _load()),
                          icon: const Icon(Icons.edit,
                              color: Color(0xFF00BFA5), size: 16),
                          label: const Text('Change',
                              style: TextStyle(
                                  color: Color(0xFF00BFA5))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  // Reminders list
                  Expanded(
                    child: _reminders.isEmpty
                        ? const Center(
                            child: Text('No reminders yet',
                                style: TextStyle(
                                    color: Colors.white54)))
                        : ListView.separated(
                            itemCount: _reminders.length,
                            separatorBuilder: (_, _) =>
                                const Divider(
                                    color: Colors.white12),
                            itemBuilder: (_, i) {
                              final r = _reminders[i];
                              return Dismissible(
                                key: Key(
                                    r.id ?? i.toString()),
                                direction:
                                    DismissDirection.endToStart,
                                background: Container(
                                  alignment:
                                      Alignment.centerRight,
                                  padding: const EdgeInsets.only(
                                      right: 20),
                                  color: Colors.redAccent,
                                  child: const Icon(
                                      Icons.delete,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) {
                                  if (r.id != null) {
                                    _delete(r.id!);
                                  }
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const CircleAvatar(
                                    backgroundColor:
                                        Colors.redAccent,
                                    child: Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                        size: 18),
                                  ),
                                  title: Text(r.title,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                  subtitle: Text(
                                      '${r.date}  ${r.time}',
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12)),
                                  trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white38),
                                ),
                              );
                            },
                          ),
                  ),
                  // Bottom buttons
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AddReminderScreen()))
                            .then((_) => _load()),
                        icon: const Icon(Icons.add,
                            color: Colors.white54, size: 16),
                        label: const Text('ADD REMINDER',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.white24)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ChangeBudgetScreen()))
                            .then((_) => _load()),
                        icon: const Icon(Icons.account_balance_wallet,
                            color: Colors.white54, size: 16),
                        label: const Text('CHANGE BUDGET',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.white24)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E8C),
        onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddReminderScreen()))
            .then((_) => _load()),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}