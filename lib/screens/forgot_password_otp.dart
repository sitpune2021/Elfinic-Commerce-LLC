import 'dart:async';
import 'package:elfinic_commerce_llc/providers/forgot%20password/forgot_password_provider.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import 'new_password_screen.dart';

class ForgotPasswordOTPScreen extends StatefulWidget {
  final String mobile; // 👈 pass mobile number

  const ForgotPasswordOTPScreen({super.key, required this.mobile});

  @override
  State<ForgotPasswordOTPScreen> createState() =>
      _ForgotPasswordOTPScreenState();
}

class _ForgotPasswordOTPScreenState extends State<ForgotPasswordOTPScreen> {
  final TextEditingController otpController = TextEditingController();

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 60;
    _isResendEnabled = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() => _isResendEnabled = true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get timerText => "00:${_remainingSeconds.toString().padLeft(2, '0')}";

  @override
  void dispose() {
    _timer?.cancel();
    // otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgotPasswordProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.indigo),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              const Text(
                "Forgot Password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              Text(
                "OTP sent to +91 ${widget.mobile}",
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 25),

              const Text(
                "Enter OTP",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.indigo),
              ),

              const SizedBox(height: 12),

              // 🔐 OTP FIELD
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.scale,
                enableActiveFill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 45,
                  activeFillColor: const Color(0xFFF3F8FB),
                  inactiveFillColor: const Color(0xFFF3F8FB),
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.indigo,
                  activeColor: Colors.indigo,
                ),
                onCompleted: (value) {
                  debugPrint("OTP Entered: $value");
                },
                onChanged: (_) {},
              ),

              const SizedBox(height: 15),

              // ⏳ TIMER + RESEND BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timerText,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: (!_isResendEnabled || provider.isLoading)
                        ? null
                        : () async {
                            final success =
                                await provider.sendOtp(widget.mobile);

                            if (success) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("OTP resent successfully")),
                              );
                              _startTimer(); // 🔁 restart timer
                            }
                          },
                    child: Text(
                      provider.isLoading ? "Sending..." : "Resend OTP",
                      style: TextStyle(
                        color: _isResendEnabled ? Colors.orange : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ▶ CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          if (otpController.text.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Enter 6 digit OTP")),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NewPasswordScreen(
                                mobile: widget.mobile,
                                otp: otpController.text,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
