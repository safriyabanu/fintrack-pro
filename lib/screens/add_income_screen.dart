import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../models/transaction_model.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});
  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _loading = false;
  String _date = DateFormat('MMM dd, yyyy').format(DateTime.now());

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: ThemeData.dark(),
        child: child!,
      ),
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
    setState(() => _loading = true);
    try {
      await DBService.insertTransaction(TransactionModel(
        type: 'income',
        amount: double.parse(_amountCtrl.text.trim()),
        tag: _noteCtrl.text.isNotEmpty
            ? _noteCtrl.text.trim()
            : '#Income',
        date: _date,
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
              child: Text('ADD INCOME',
                  style: TextStyle(
                      color: Color(0xFF00BFA5),
                      fontSize: 14,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
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
            const SizedBox(height: 24),
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
                    color: Color(0xFF8BC34A), fontSize: 32),
              ),
            ),
            const SizedBox(height: 24),
            // Note
            const Text('Note (optional)',
                style: TextStyle(
                    color: Colors.white54, fontSize: 12)),
            TextField(
              controller: _noteCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '#Income',
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 16),
            // Tag
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF8BC34A).withAlpha((255 * 0.2).round()),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF8BC34A), width: 1),
              ),
              child: const Text('#Income',
                  style: TextStyle(
                      color: Color(0xFF8BC34A), fontSize: 13)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E8C),
        onPressed: _loading ? null : _save,
        child: _loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}