import 'package:elfinic_commerce_llc/providers/forgot%20password/forgot_password_provider.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import 'forgot_password_otp.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.indigo),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              const Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "Select option to reset password",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 25),

              const Text("Via Mobile Number",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  )),
              const SizedBox(height: 5),

              IntlPhoneField(
                controller: mobileController,
                decoration: InputDecoration(
                  hintText: "Mobile Number",
                  counterText: "", 
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                initialCountryCode: 'IN',
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Consumer<ForgotPasswordProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading
                          ? null // 🚫 prevents double click
                          : () async {
                              final mobile = mobileController.text.trim();

                              if (mobile.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Please enter mobile number")),
                                );
                                return;
                              }

                              final success = await provider.sendOtp(mobile);

                              if (success && context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPasswordOTPScreen(
                                      mobile: mobileController.text.trim(),
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 22, height: 22, child: CustomLoader())
                          : const Text(
                              "CONTINUE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
