import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import '../models/reminder_model.dart';

class DBService {
  static final _db = FirebaseFirestore.instance;

  // Get current user UID
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ─── USER PROFILE ────────────────────────────────────────
  static Future<void> saveUserProfile(
      String name, String phone, double budget) async {
    await _db.collection('users').doc(_uid).set({
      'name': name,
      'phone': phone,
      'email': FirebaseAuth.instance.currentUser!.email,
      'budget': budget,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.data();
  }

  // ─── TRANSACTIONS ─────────────────────────────────────────
  static Future<void> insertTransaction(
      TransactionModel t) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .add(t.toMap());
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => TransactionModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  static Future<void> deleteTransaction(String id) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  // ─── BUDGET ───────────────────────────────────────────────
  static Future<void> setBudget(double amount) async {
    await _db
        .collection('users')
        .doc(_uid)
        .update({'budget': amount});
  }

  static Future<double> getBudget() async {
    final doc =
        await _db.collection('users').doc(_uid).get();
    return (doc.data()?['budget'] ?? 0).toDouble();
  }

  // ─── REMINDERS ────────────────────────────────────────────
  static Future<void> insertReminder(ReminderModel r) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('reminders')
        .add(r.toMap());
  }

  static Future<List<ReminderModel>> getReminders() async {
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('reminders')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((d) => ReminderModel.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  static Future<void> deleteReminder(String id) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('reminders')
        .doc(id)
        .delete();
  }
  // ─── CLEAR ALL TRANSACTIONS ───────────────────────────────
  static Future<void> clearAllTransactions() async {
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('transactions')
        .get();
    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  // ─── CLEAR ALL REMINDERS ──────────────────────────────────
  static Future<void> clearAllReminders() async {
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('reminders')
        .get();
    for (var doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}