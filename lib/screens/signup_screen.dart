import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import 'login_screen.dart';
import 'otp_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _signup() async {
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill all fields')));
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.signUp(
          _emailCtrl.text.trim(), _passCtrl.text.trim());
      final budget = _budgetCtrl.text.isNotEmpty
          ? double.parse(_budgetCtrl.text.trim())
          : 0.0;
      await DBService.saveUserProfile(
          _nameCtrl.text.trim(),
          _phoneCtrl.text.trim(),
          budget);
      // Generate 6 digit OTP
      final otp =
          (100000 + Random().nextInt(900000)).toString();
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => OtpScreen(
                      email: _emailCtrl.text.trim(),
                      name: _nameCtrl.text.trim(),
                      otp: otp,
                    )));
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed!';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered!';
      } else if (e.code == 'weak-password') {
        message = 'Password must be at least 6 characters!';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address!';
      } else {
        message = e.message ?? 'Signup failed!';
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Signup failed! Try again.')));
      }
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('FinTrack Pro',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const SizedBox(height: 8),
              const Text('SIGN UP',
                  style: TextStyle(
                      fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 24),
              _field(_nameCtrl, 'Name', Icons.person),
              _field(_emailCtrl, 'Email', Icons.email),
              _field(_phoneCtrl, 'Phone Number', Icons.phone,
                  type: TextInputType.phone),
              _field(_passCtrl, 'Password', Icons.lock,
                  obscure: true),
              _field(
                  _budgetCtrl,
                  'Monthly Budget (optional)',
                  Icons.account_balance_wallet,
                  type: TextInputType.number),
              const SizedBox(height: 24),
              // Signup button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14)),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('SIGN UP',
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              // Login link
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen())),
                child: const Text(
                  'Already have an Account? Login here.',
                  style: TextStyle(
                      color: Color(0xFF00BFA5),
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController c, String label, IconData icon,
      {bool obscure = false,
      TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        obscureText: obscure,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.white38),
        ),
      ),
    );
  }
}