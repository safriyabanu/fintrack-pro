import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

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
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.document_scanner,
                  size: 80, color: Colors.white24),
              SizedBox(height: 20),
              Text(
                '📱 Bill scanning is only available\non the Android app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white54, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Use the Android version to scan bills.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}