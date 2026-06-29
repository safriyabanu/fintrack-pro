import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:js_interop';
import 'login_screen.dart';

@JS('sendOTPEmail')
external JSPromise sendOTPEmail(
    String toEmail, String toName, String otpCode);

class OtpScreen extends StatefulWidget {
  final String email;
  final String name;
  final String otp;

  const OtpScreen({
    super.key,
    required this.email,
    required this.name,
    required this.otp,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _loading = false;
  bool _resendLoading = false;
  int _resendTimer = 30;
  Timer? _timer;
  String? _currentOtp;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.otp;
    Future.delayed(const Duration(seconds: 2), () {
      _sendOTP();
    });
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 30;
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _sendOTP() async {
    try {
      debugPrint(
          '📧 Sending OTP: $_currentOtp to ${widget.email}');
      await sendOTPEmail(
              widget.email, widget.name, _currentOtp!)
          .toDart;
      debugPrint('✅ OTP sent successfully!');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Color(0xFF00BFA5),
                content: Text(
                    '✅ OTP sent! Check your email.')));
      }
    } catch (e, stack) {
      debugPrint('❌ Email error: ${e.toString()}');
      debugPrint('❌ Stack: $stack');
      // Try again after 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      try {
        debugPrint('🔄 Retrying...');
        await sendOTPEmail(
                widget.email, widget.name, _currentOtp!)
            .toDart;
        debugPrint('✅ OTP sent on retry!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  backgroundColor: Color(0xFF00BFA5),
                  content:
                      Text('✅ OTP sent! Check your email.')));
        }
      } catch (e2, stack2) {
        debugPrint('❌ Retry failed: ${e2.toString()}');
        debugPrint('❌ Retry stack: $stack2');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text(
                      '❌ Failed to send OTP. Please try resend.')));
        }
      }
    }
  }

  String _generateNewOtp() {
    final random =
        DateTime.now().millisecondsSinceEpoch % 900000 +
            100000;
    return random.toString();
  }

  Future<void> _resendOTP() async {
    setState(() => _resendLoading = true);
    _currentOtp = _generateNewOtp();
    for (var c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    await _sendOTP();
    _startResendTimer();
    setState(() => _resendLoading = false);
  }

  void _verifyOTP() {
    final enteredOtp =
        _controllers.map((c) => c.text).join();
    if (enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please enter all 6 digits!')));
      return;
    }
    if (_attempts >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Too many attempts! Please resend OTP.')));
      return;
    }
    setState(() => _loading = true);
    if (enteredOtp == _currentOtp) {
      setState(() => _loading = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
                color: Color(0xFF00BFA5), width: 1),
          ),
          title: const Row(children: [
            Text('✅ ', style: TextStyle(fontSize: 24)),
            Text('Verified!',
                style: TextStyle(
                    color: Color(0xFF00BFA5),
                    fontWeight: FontWeight.bold)),
          ]),
          content: const Text(
            'Your email has been verified!\nYou can now login.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen()),
                    (route) => false);
              },
              child: const Text('GO TO LOGIN',
                  style: TextStyle(
                      color: Color(0xFF00BFA5),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      _attempts++;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Wrong OTP! ${3 - _attempts} attempts remaining.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('FinTrack Pro',
            style: TextStyle(color: Color(0xFF00BFA5))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF00BFA5).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read,
                  color: Color(0xFF00BFA5), size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Verify Your Email',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit OTP to\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 12),
            // Check spam notice
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.orange.withAlpha(80)),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline,
                    color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Check your spam/junk folder if you don\'t see the email!',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            // OTP input boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                return Container(
                  width: 45,
                  height: 55,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 4),
                  child: TextField(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF00BFA5),
                            width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && i < 5) {
                        _focusNodes[i + 1].requestFocus();
                      }
                      if (value.isEmpty && i > 0) {
                        _focusNodes[i - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF00BFA5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 14)),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text('VERIFY OTP',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            _resendTimer > 0
                ? Text(
                    'Resend OTP in $_resendTimer seconds',
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13),
                  )
                : TextButton(
                    onPressed: _resendLoading
                        ? null
                        : _resendOTP,
                    child: _resendLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF00BFA5))
                        : const Text('Resend OTP',
                            style: TextStyle(
                                color: Color(0xFF00BFA5),
                                fontWeight:
                                    FontWeight.bold)),
                  ),
            const SizedBox(height: 12),
            if (_attempts > 0)
              Text(
                '${3 - _attempts} attempts remaining',
                style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}