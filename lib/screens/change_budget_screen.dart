import 'package:flutter/material.dart';
import '../services/db_service.dart';

class ChangeBudgetScreen extends StatefulWidget {
  const ChangeBudgetScreen({super.key});
  @override
  State<ChangeBudgetScreen> createState() =>
      _ChangeBudgetScreenState();
}

class _ChangeBudgetScreenState extends State<ChangeBudgetScreen> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  double _currentBudget = 0;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final b = await DBService.getBudget();
    setState(() {
      _currentBudget = b;
      if (b > 0) _ctrl.text = b.toStringAsFixed(0);
    });
  }

  Future<void> _save() async {
    if (_ctrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a budget amount')));
      return;
    }
    setState(() => _loading = true);
    try {
      await DBService.setBudget(
          double.parse(_ctrl.text.trim()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Budget updated successfully!')));
        Navigator.pop(context);
      }
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
              child: Text('SET BUDGET',
                  style: TextStyle(
                      color: Color(0xFF00BFA5),
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
            // Current budget display
            if (_currentBudget > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Color(0xFF00BFA5), size: 20),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text('Current Budget',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11)),
                      Text(
                        '₹ ${_currentBudget.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 24),
            ],
            // New budget input
            const Text('Set Monthly Budget (₹)',
                style: TextStyle(
                    color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  color: Colors.white, fontSize: 32),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.white24),
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                    color: Color(0xFF00BFA5), fontSize: 32),
              ),
            ),
            const SizedBox(height: 24),
            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.orange.withAlpha((255 * 0.3).round())),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will receive an alert when you spend more than half of your monthly budget.',
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12),
                    ),
                  ),
                ],
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
            : const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}