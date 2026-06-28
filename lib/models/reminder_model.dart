import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  String? id;
  String title;
  String date;
  String time;

  ReminderModel({
    this.id,
    required this.title,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'date': date,
    'time': time,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory ReminderModel.fromMap(Map<String, dynamic> map) =>
      ReminderModel(
        id: map['id'],
        title: map['title'],
        date: map['date'],
        time: map['time'],
      );
}