import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:js_interop';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/theme_service.dart';
import '../models/transaction_model.dart';
import 'add_income_screen.dart';
import 'add_expense_screen.dart';
import 'scan_screen.dart';
import 'transactions_screen.dart';
import 'alerts_screen.dart';
import 'login_screen.dart';
import 'monthly_report_screen.dart';

@JS('playReminderSound')
external void playReminderSound();

@JS('stopReminderSound')
external void stopReminderSound();

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TransactionModel> _transactions = [];
  double income = 0, expense = 0;
  String _userName = '';
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _startReminderChecker();
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final list = await DBService.getTransactions();
    final profile = await DBService.getUserProfile();
    double inc = 0, exp = 0;
    for (var t in list) {
      if (t.type == 'income') {
        inc += t.amount;
      } else {
        exp += t.amount;
      }
    }
    setState(() {
      _transactions = list;
      income = inc;
      expense = exp;
      _userName = profile?['name'] ?? '';
    });
  }

  void _startReminderChecker() {
    _checkReminders();
    _reminderTimer =
        Timer.periodic(const Duration(minutes: 1), (_) {
      _checkReminders();
    });
  }

  Future<void> _checkReminders() async {
    if (!mounted) return;
    final now = DateTime.now();
    final currentTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final currentDate =
        '${now.day}/${now.month}/${now.year}';
    final reminders = await DBService.getReminders();
    for (var reminder in reminders) {
      if (reminder.time == currentTime &&
          (reminder.date == currentDate ||
              reminder.date == '')) {
        if (mounted) {
          _showReminderAlert(reminder.title);
        }
      }
    }
  }

  void _playAlertSound() {
    try {
      playReminderSound();
    } catch (e) {
      debugPrint('Sound error: $e');
    }
  }

  void _stopAlertSound() {
    try {
      stopReminderSound();
    } catch (e) {
      debugPrint('Stop sound error: $e');
    }
  }

  void _showReminderAlert(String title) {
    _playAlertSound();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
              color: Color(0xFF00BFA5), width: 1),
        ),
        title: const Row(children: [
          Text('🔔 ', style: TextStyle(fontSize: 24)),
          Text('Reminder!',
              style: TextStyle(
                  color: Color(0xFF00BFA5),
                  fontWeight: FontWeight.bold)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_active,
                color: Color(0xFF00BFA5), size: 48),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text(
              '🔊 Sound will stop when dismissed',
              style: TextStyle(
                  color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _stopAlertSound();
              Navigator.pop(context);
            },
            child: const Text('DISMISS',
                style: TextStyle(
                    color: Color(0xFF00BFA5),
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (_) => const LoginScreen()));
    }
  }

  void _showAddOptions() {
    final isDark =
        Provider.of<ThemeService>(context, listen: false)
            .isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text('Add Transaction',
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Divider(
              color: isDark ? Colors.white12 : Colors.black12),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF8BC34A),
              child: Icon(Icons.arrow_upward,
                  color: Colors.white),
            ),
            title: Text('Add Income',
                style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Colors.black87)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const AddIncomeScreen()))
                  .then((_) => _load());
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Icon(Icons.arrow_downward,
                  color: Colors.white),
            ),
            title: Text('Add Expense',
                style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Colors.black87)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const AddExpenseScreen()))
                  .then((_) => _load());
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final isDark = themeService.isDark;
    final recent = _transactions.take(5).toList();
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final cardColor =
        isDark ? const Color(0xFF1A1A2E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FinTrack Pro',
                style: TextStyle(
                    color: Color(0xFF00BFA5), fontSize: 16)),
            if (_userName.isNotEmpty)
              Text('Welcome, $_userName!',
                  style: TextStyle(
                      color: subColor, fontSize: 12)),
          ],
        ),
        actions: [
          // 🌙 Theme toggle
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            onPressed: () => themeService.toggleTheme(),
            tooltip: isDark
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
          // 📊 Monthly Report
          IconButton(
            icon: Icon(Icons.bar_chart,
                color:
                    isDark ? Colors.white54 : Colors.black54),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const MonthlyReportScreen())),
            tooltip: 'Monthly Report',
          ),
          TextButton(
            onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AlertsScreen()))
                .then((_) => _load()),
            child: const Text('Alerts',
                style: TextStyle(color: Color(0xFF00BFA5))),
          ),
          TextButton(
            onPressed: _logout,
            child: Text('Logout',
                style: TextStyle(color: subColor)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Pie Chart
              SizedBox(
                height: 200,
                child: income + expense == 0
                    ? Center(
                        child: Text('No transactions yet',
                            style:
                                TextStyle(color: subColor)))
                    : PieChart(PieChartData(
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: income,
                            color: const Color(0xFF8BC34A),
                            title: 'Income',
                            radius: 70,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12),
                          ),
                          PieChartSectionData(
                            value: expense,
                            color: Colors.redAccent,
                            title: 'Expense',
                            radius: 70,
                            titleStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12),
                          ),
                        ],
                      )),
              ),
              const SizedBox(height: 16),
              // Income / Expense / Balance totals
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _totalCard('INCOME',
                      '₹ ${income.toStringAsFixed(0)}',
                      const Color(0xFF8BC34A)),
                  _totalCard('EXPENSE',
                      '₹ ${expense.toStringAsFixed(0)}',
                      Colors.redAccent),
                  _totalCard(
                      'BALANCE',
                      '₹ ${(income - expense).toStringAsFixed(0)}',
                      const Color(0xFF00BFA5)),
                ],
              ),
              const SizedBox(height: 20),
              // Recent transactions header
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECENT TRANSACTIONS',
                      style: TextStyle(
                          color: subColor, fontSize: 12)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const TransactionsScreen()))
                        .then((_) => _load()),
                    child: const Text('Show All',
                        style: TextStyle(
                            color: Color(0xFF00BFA5),
                            fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Recent transactions list
              recent.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('No transactions yet',
                          style: TextStyle(color: subColor)),
                    )
                  : Column(
                      children: recent
                          .map((t) => Container(
                                margin: const EdgeInsets.only(
                                    bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: isDark
                                          ? Colors.white12
                                          : Colors.black12),
                                ),
                                child: Row(children: [
                                  CircleAvatar(
                                    backgroundColor: t.type ==
                                            'income'
                                        ? const Color(0xFF8BC34A)
                                            .withAlpha((255 * 0.2)
                                                .round())
                                        : Colors.redAccent
                                            .withAlpha((255 * 0.2)
                                                .round()),
                                    child: Icon(
                                      t.type == 'income'
                                          ? Icons.arrow_upward
                                          : Icons.arrow_downward,
                                      color: t.type == 'income'
                                          ? const Color(0xFF8BC34A)
                                          : Colors.redAccent,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(t.tag,
                                            style: TextStyle(
                                                color: textColor,
                                                fontWeight:
                                                    FontWeight.w500)),
                                        Text(t.date,
                                            style: TextStyle(
                                                color: subColor,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${t.type == 'income' ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: t.type == 'income'
                                          ? const Color(0xFF8BC34A)
                                          : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]),
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        child: Row(children: [
          _bottomBtn(
              Icons.qr_code_scanner,
              'SCAN',
              () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ScanScreen()))
                  .then((_) => _load()),
              isDark),
          const SizedBox(width: 8),
          _bottomBtn(
              Icons.list_alt,
              'HISTORY',
              () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const TransactionsScreen()))
                  .then((_) => _load()),
              isDark),
          const SizedBox(width: 8),
          _bottomBtn(
              Icons.notifications,
              'ALERTS',
              () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const AlertsScreen()))
                  .then((_) => _load()),
              isDark),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E8C),
        onPressed: _showAddOptions,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _totalCard(
      String label, String value, Color color) {
    return Column(children: [
      Text(label,
          style: TextStyle(color: color, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _bottomBtn(IconData icon, String label,
      VoidCallback onTap, bool isDark) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon,
            size: 16,
            color: isDark ? Colors.white54 : Colors.black54),
        label: Text(label,
            style: TextStyle(
                color: isDark
                    ? Colors.white54
                    : Colors.black54,
                fontSize: 11)),
        style: OutlinedButton.styleFrom(
            side: BorderSide(
                color: isDark
                    ? Colors.white24
                    : Colors.black12)),
      ),
    );
  }
}