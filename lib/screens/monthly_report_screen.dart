import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import '../models/transaction_model.dart';
import '../services/theme_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});
  @override
  State<MonthlyReportScreen> createState() =>
      _MonthlyReportScreenState();
}

class _MonthlyReportScreenState
    extends State<MonthlyReportScreen> {
  List<TransactionModel> _txns = [];
  bool _loading = true;

  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final txns = await DBService.getTransactions();
    setState(() {
      _txns = txns;
      _loading = false;
    });
  }

  double _getMonthlyIncome(int month, int year) {
    return _txns
        .where((t) =>
            t.type == 'income' &&
            _parseMonth(t.date) == month &&
            _parseYear(t.date) == year)
        .fold(0, (s, t) => s + t.amount);
  }

  double _getMonthlyExpense(int month, int year) {
    return _txns
        .where((t) =>
            t.type == 'expense' &&
            _parseMonth(t.date) == month &&
            _parseYear(t.date) == year)
        .fold(0, (s, t) => s + t.amount);
  }

  int _parseMonth(String date) {
    try {
      final parts = date.split(' ');
      return _months.indexOf(parts[0]) + 1;
    } catch (_) {
      return 0;
    }
  }

  int _parseYear(String date) {
    try {
      final parts = date.split(' ');
      return int.parse(parts[2].replaceAll(',', ''));
    } catch (_) {
      return 0;
    }
  }

  List<Map<String, dynamic>> _getLast6Months() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final month = date.month;
      final year = date.year;
      final inc = _getMonthlyIncome(month, year);
      final exp = _getMonthlyExpense(month, year);
      data.add({
        'month': _months[month - 1],
        'income': inc,
        'expense': exp,
        'balance': inc - exp,
      });
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Provider.of<ThemeService>(context).isDark;
    final textColor =
        isDark ? Colors.white : Colors.black87;
    final subColor =
        isDark ? Colors.white54 : Colors.black54;
    final cardColor =
        isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final bgColor = isDark
        ? const Color(0xFF0D1117)
        : const Color(0xFFF5F5F5);

    final monthlyData = _getLast6Months();
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    final totalIncome =
        _getMonthlyIncome(currentMonth, currentYear);
    final totalExpense =
        _getMonthlyExpense(currentMonth, currentYear);
    final totalBalance = totalIncome - totalExpense;

    double maxVal = 1000;
    for (var d in monthlyData) {
      if ((d['income'] as double) > maxVal) {
        maxVal = d['income'];
      }
      if ((d['expense'] as double) > maxVal) {
        maxVal = d['expense'];
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color:
                  isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Monthly Report',
            style: TextStyle(
                color: Color(0xFF00BFA5), fontSize: 16)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF00BFA5)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ── This Month Summary ──
                  Text('THIS MONTH',
                      style: TextStyle(
                          color: subColor,
                          fontSize: 11,
                          letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Row(children: [
                    _summaryCard(
                        'Income',
                        '₹${totalIncome.toStringAsFixed(0)}',
                        const Color(0xFF8BC34A),
                        cardColor,
                        textColor),
                    const SizedBox(width: 8),
                    _summaryCard(
                        'Expense',
                        '₹${totalExpense.toStringAsFixed(0)}',
                        Colors.redAccent,
                        cardColor,
                        textColor),
                    const SizedBox(width: 8),
                    _summaryCard(
                        'Balance',
                        '₹${totalBalance.toStringAsFixed(0)}',
                        const Color(0xFF00BFA5),
                        cardColor,
                        textColor),
                  ]),
                  const SizedBox(height: 24),

                  // ── Bar Chart ──
                  Text('LAST 6 MONTHS',
                      style: TextStyle(
                          color: subColor,
                          fontSize: 11,
                          letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : Colors.black12),
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          _legendItem('Income',
                              const Color(0xFF8BC34A),
                              subColor),
                          const SizedBox(width: 16),
                          _legendItem('Expense',
                              Colors.redAccent, subColor),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment
                                .spaceAround,
                            maxY: maxVal * 1.2,
                            barTouchData: BarTouchData(
                                enabled: true),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget:
                                      (value, meta) {
                                    final idx =
                                        value.toInt();
                                    if (idx >= 0 && idx < monthlyData.length) {
                                      return Text(
                                        monthlyData[idx]
                                            ['month'],
                                        style: TextStyle(
                                            color: subColor,
                                            fontSize: 10),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget:
                                      (value, meta) {
                                    return Text(
                                      '₹${value.toInt()}',
                                      style: TextStyle(
                                          color: subColor,
                                          fontSize: 9),
                                    );
                                  },
                                ),
                              ),
                              topTitles:
                                  const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false)),
                              rightTitles:
                                  const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              getDrawingHorizontalLine:
                                  (value) => FlLine(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black12,
                                strokeWidth: 0.5,
                              ),
                            ),
                            borderData:
                                FlBorderData(show: false),
                            barGroups: monthlyData
                                .asMap()
                                .entries
                                .map((e) =>
                                    BarChartGroupData(
                                      x: e.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: e.value[
                                              'income'],
                                          color: const Color(
                                              0xFF8BC34A),
                                          width: 10,
                                          borderRadius:
                                              const BorderRadius
                                                  .vertical(
                                                  top: Radius
                                                      .circular(
                                                          4)),
                                        ),
                                        BarChartRodData(
                                          toY: e.value[
                                              'expense'],
                                          color: Colors
                                              .redAccent,
                                          width: 10,
                                          borderRadius:
                                              const BorderRadius
                                                  .vertical(
                                                  top: Radius
                                                      .circular(
                                                          4)),
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // ── Monthly Breakdown ──
                  Text('MONTHLY BREAKDOWN',
                      style: TextStyle(
                          color: subColor,
                          fontSize: 11,
                          letterSpacing: 1)),
                  const SizedBox(height: 12),
                  ...monthlyData.reversed
                      .map((d) => Container(
                            margin: const EdgeInsets.only(
                                bottom: 10),
                            padding:
                                const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12),
                            ),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(d['month'],
                                        style: TextStyle(
                                            color: textColor,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize: 14)),
                                    Text(
                                      (d['balance']
                                                  as double) >=
                                              0
                                          ? '+₹${(d['balance'] as double).toStringAsFixed(0)}'
                                          : '-₹${(d['balance'] as double).abs().toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: (d['balance']
                                                    as double) >=
                                                0
                                            ? const Color(
                                                0xFF8BC34A)
                                            : Colors
                                                .redAccent,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ]),
                              const SizedBox(height: 8),
                              Row(children: [
                                Expanded(
                                  child: _miniStat(
                                      'Income',
                                      '₹${(d['income'] as double).toStringAsFixed(0)}',
                                      const Color(
                                          0xFF8BC34A),
                                      subColor),
                                ),
                                Expanded(
                                  child: _miniStat(
                                      'Expense',
                                      '₹${(d['expense'] as double).toStringAsFixed(0)}',
                                      Colors.redAccent,
                                      subColor),
                                ),
                              ]),
                              const SizedBox(height: 8),
                              if ((d['income'] as double) >
                                  0) ...[
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                          4),
                                  child:
                                      LinearProgressIndicator(
                                    value: ((d['expense']
                                                as double) /
                                            (d['income']
                                                as double))
                                        .clamp(0.0, 1.0),
                                    backgroundColor: isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                    color: (d['expense']
                                                as double) >
                                            (d['income']
                                                as double)
                                        ? Colors.redAccent
                                        : const Color(
                                            0xFF00BFA5),
                                    minHeight: 6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(((d['expense'] as double) / (d['income'] as double)) * 100).clamp(0, 100).toStringAsFixed(0)}% of income spent',
                                  style: TextStyle(
                                      color: subColor,
                                      fontSize: 10),
                                ),
                              ],
                            ]),
                          )),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String label, String value,
      Color color, Color cardColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(
      String label, Color color, Color subColor) {
    return Row(children: [
      Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 4),
      Text(label,
          style:
              TextStyle(color: subColor, fontSize: 11)),
    ]);
  }

  Widget _miniStat(String label, String value,
      Color color, Color subColor) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: subColor, fontSize: 10)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ]);
  }
}