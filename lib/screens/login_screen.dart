import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await AuthService.login(
          _emailCtrl.text.trim(), _passCtrl.text.trim());
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const DashboardScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')));
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              const Text('LOGIN',
                  style: TextStyle(
                      fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 30),
              // Email
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon:
                      Icon(Icons.email, color: Colors.white38),
                ),
              ),
              const SizedBox(height: 12),
              // Password
              TextField(
                controller: _passCtrl,
                obscureText: !_showPass,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon:
                      const Icon(Icons.lock, color: Colors.white38),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _showPass
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white38),
                    onPressed: () =>
                        setState(() => _showPass = !_showPass),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Show password checkbox
              Row(children: [
                Checkbox(
                  value: _showPass,
                  onChanged: (v) =>
                      setState(() => _showPass = v!),
                  activeColor: const Color(0xFF00BFA5),
                ),
                const Text('Show Password',
                    style: TextStyle(color: Colors.white54)),
              ]),
              const SizedBox(height: 20),
              // Login button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14)),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('LOGIN',
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              // Sign up link
              GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SignupScreen())),
                child: const Text(
                  'Not a Member yet? Sign Up here.',
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
}