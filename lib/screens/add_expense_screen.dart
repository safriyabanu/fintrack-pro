import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../models/transaction_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final double? prefilledAmount;
  const AddExpenseScreen({super.key, this.prefilledAmount});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountCtrl = TextEditingController();
  final _customCategoryCtrl = TextEditingController();
  String _selectedTag = '';
  bool _loading = false;
  bool _showCustomField = false;
  String _date = DateFormat('MMM dd, yyyy').format(DateTime.now());

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Transport', 'icon': Icons.directions_bus, 'color': Colors.blue},
    {'label': 'Food', 'icon': Icons.fastfood, 'color': Colors.green},
    {'label': 'Bills', 'icon': Icons.receipt, 'color': Colors.orange},
    {'label': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.cyan},
    {'label': 'Home', 'icon': Icons.home, 'color': Colors.red},
    {'label': 'Pets', 'icon': Icons.pets, 'color': Colors.brown},
    {'label': 'Education', 'icon': Icons.school, 'color': Colors.purple},
    {'label': 'Travel', 'icon': Icons.flight, 'color': Colors.teal},
    {'label': 'Beauty', 'icon': Icons.face, 'color': Colors.pink},
    {'label': 'Kids', 'icon': Icons.child_care, 'color': Colors.lightGreen},
    {'label': 'Healthcare', 'icon': Icons.local_hospital, 'color': Colors.indigo},
    {'label': 'Movie', 'icon': Icons.movie, 'color': Colors.yellow},
    {'label': 'Other', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.prefilledAmount != null) {
      _amountCtrl.text = widget.prefilledAmount!.toString();
    }
  }

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
        _date = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (_amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter amount')));
      return;
    }
    if (_selectedTag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')));
      return;
    }
    // If Other is selected, custom field must be filled
    if (_selectedTag == 'Other' && _customCategoryCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your custom category')));
      return;
    }

    setState(() => _loading = true);
    try {
      final amount = double.parse(_amountCtrl.text.trim());

      // Use custom category name if Other is selected
      final String finalTag = _selectedTag == 'Other'
          ? _customCategoryCtrl.text.trim()
          : _selectedTag;

      await DBService.insertTransaction(TransactionModel(
        type: 'expense',
        amount: amount,
        tag: finalTag,
        date: _date,
      ));

      // ── Get all transactions ──
      final txns = await DBService.getTransactions();

      // ── Calculate totals ──
      double totalIncome = txns
          .where((t) => t.type == 'income')
          .fold(0, (s, t) => s + t.amount);
      double totalExpense = txns
          .where((t) => t.type == 'expense')
          .fold(0, (s, t) => s + t.amount);

      // ── Get manual budget ──
      double manualBudget = await DBService.getBudget();

      // ── Use manual budget if set, else use income ──
      double budgetLimit =
          manualBudget > 0 ? manualBudget : totalIncome;

      // ── Alert if spent 50% or more ──
      if (budgetLimit > 0 &&
          totalExpense >= budgetLimit * 0.5 &&
          mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A2E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.orange, width: 1),
            ),
            title: const Row(children: [
              Text('⚠️ ', style: TextStyle(fontSize: 24)),
              Text('Budget Alert!',
                  style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold)),
            ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manualBudget > 0
                      ? 'You have spent ₹${totalExpense.toStringAsFixed(0)} out of your ₹${budgetLimit.toStringAsFixed(0)} set budget!'
                      : 'You have spent ₹${totalExpense.toStringAsFixed(0)} which is more than 50% of your total income ₹${totalIncome.toStringAsFixed(0)}!',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (totalExpense / budgetLimit)
                        .clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    color: totalExpense >= budgetLimit
                        ? Colors.red
                        : Colors.orange,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${((totalExpense / budgetLimit) * 100).clamp(0, 100).toStringAsFixed(0)}% of budget used',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 12),
                const Text(
                  '💡 Spend money wisely !',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK, I will be careful!',
                    style: TextStyle(
                        color: Color(0xFF00BFA5),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text('ADD EXPENSE',
                  style: TextStyle(
                      color: Color(0xFF00BFA5),
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            // Date picker
            GestureDetector(
              onTap: _pickDate,
              child: Row(children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white38, size: 18),
                const SizedBox(width: 8),
                Text(_date,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                const SizedBox(width: 8),
                const Text('(tap to change)',
                    style: TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ]),
            ),
            const SizedBox(height: 16),
            // Amount
            const Text('Amount (₹)',
                style: TextStyle(
                    color: Colors.white54, fontSize: 12)),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  color: Colors.white, fontSize: 32),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.white24),
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                    color: Colors.redAccent, fontSize: 32),
              ),
            ),
            const SizedBox(height: 16),
            // Category label
            const Text('Select Category',
                style: TextStyle(
                    color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 10),
            // Categories grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: _categories.map((c) {
                  final selected = _selectedTag == c['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTag = c['label'];
                        // Show custom field only for Other
                        _showCustomField = c['label'] == 'Other';
                        if (!_showCustomField) {
                          _customCategoryCtrl.clear();
                        }
                      });
                    },
                    child: Column(children: [
                      CircleAvatar(
                        backgroundColor: selected
                            ? c['color']
                            : (c['color'] as Color)
                                .withValues(alpha: 0.3),
                        child: Icon(c['icon'] as IconData,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(c['label'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.white54,
                              fontSize: 10)),
                    ]),
                  );
                }).toList(),
              ),
            ),
            // Custom category text field
            // Shows only when Other is selected
            if (_showCustomField) ...[
              const SizedBox(height: 12),
              const Text('Enter your category',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: _customCategoryCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Gym, Rent, Gift...',
                  hintStyle:
                      const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.edit,
                      color: Colors.white38, size: 18),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Color(0xFF00BFA5)),
                  ),
                ),
              ),
            ],
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