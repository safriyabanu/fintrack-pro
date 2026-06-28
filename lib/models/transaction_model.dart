import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? id;
  String type;      // 'income' or 'expense'
  double amount;
  String tag;
  String date;

  TransactionModel({
    this.id,
    required this.type,
    required this.amount,
    required this.tag,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'type': type,
    'amount': amount,
    'tag': tag,
    'date': date,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory TransactionModel.fromMap(Map<String, dynamic> map) =>
      TransactionModel(
        id: map['id'],
        type: map['type'],
        amount: (map['amount'] as num).toDouble(),
        tag: map['tag'],
        date: map['date'],
      );
}