import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/db_service.dart';
import '../models/transaction_model.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<TransactionModel> _txns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final t = await DBService.getTransactions();
    setState(() {
      _txns = t;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await DBService.deleteTransaction(id);
    _load();
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: const Text('⚠️ Clear All Transactions?',
            style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          'This will permanently delete ALL your income and expense records. This cannot be undone!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE ALL',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBService.clearAllTransactions();
      _load();
    }
  }

  Map<String, double> get _expenseByTag {
    final Map<String, double> map = {};
    for (var t in _txns.where((t) => t.type == 'expense')) {
      map[t.tag] = (map[t.tag] ?? 0) + t.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.cyan,
      Colors.red,
      Colors.teal,
      Colors.yellow,
      Colors.indigo,
      Colors.brown,
      Colors.lime,
    ];
    final tagMap = _expenseByTag;
    final tags = tagMap.keys.toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('FinTrack Pro',
            style: TextStyle(color: Color(0xFF00BFA5))),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: const Color(0xFF00BFA5),
          tabs: const [
            Tab(text: 'ALL TRANSACTIONS'),
            Tab(text: 'EXPENSE CHART'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF00BFA5)))
          : TabBarView(
              controller: _tab,
              children: [
                // ── Tab 1: All Transactions ──
                _txns.isEmpty
                    ? const Center(
                        child: Text('No transactions yet',
                            style: TextStyle(
                                color: Colors.white54)))
                    : Column(children: [
                        // Clear all button
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _confirmClearAll(context),
                              icon: const Icon(
                                  Icons.delete_sweep,
                                  color: Colors.redAccent,
                                  size: 18),
                              label: const Text(
                                  'Clear All Transactions',
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.redAccent)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _txns.length,
                            separatorBuilder: (_, _) =>
                                const Divider(
                                    color: Colors.white12),
                            itemBuilder: (_, i) {
                              final t = _txns[i];
                              return Dismissible(
                                key: Key(t.id ?? i.toString()),
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
                                  if (t.id != null) {
  _delete(t.id!);
}
                                },
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: t.type ==
                                            'income'
                                        ? const Color(0xFF8BC34A)
                                            .withValues(alpha: 0.2)
                                        : Colors.redAccent
                                            .withValues(alpha: 0.2),
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
                                  title: Text(t.tag,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                  subtitle: Text(t.date,
                                      style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12)),
                                  trailing: Text(
                                    '${t.type == 'income' ? '+' : '-'}₹${t.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: t.type == 'income'
                                          ? const Color(0xFF8BC34A)
                                          : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ]),

                // ── Tab 2: Expense Pie Chart ──
                tagMap.isEmpty
                    ? const Center(
                        child: Text('No expenses yet',
                            style: TextStyle(
                                color: Colors.white54)))
                    : Column(children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: PieChart(PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: tags
                                .asMap()
                                .entries
                                .map((e) => PieChartSectionData(
                                      value: tagMap[e.value],
                                      color: colors[
                                          e.key % colors.length],
                                      title: e.value,
                                      titleStyle: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white),
                                      radius: 80,
                                    ))
                                .toList(),
                          )),
                        ),
                        const SizedBox(height: 16),
                        // Legend
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: tags
                              .asMap()
                              .entries
                              .map((e) => Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: colors[e.key %
                                              colors.length],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${e.value} ₹${tagMap[e.value]!.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ]),
              ],
            ),
    );
  }
}