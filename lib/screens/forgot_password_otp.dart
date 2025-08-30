import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'new_password_screen.dart';

class ForgotPasswordOTPScreen extends StatefulWidget {
  const ForgotPasswordOTPScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordOTPScreen> createState() => _ForgotPasswordOTPScreenState();
}

class _ForgotPasswordOTPScreenState extends State<ForgotPasswordOTPScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "OTP sent to your entered mobile number +91 85377 XXXXX",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 25),

              const Text(
                "Enter OTP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),

              // PinCodeTextField(
              //   appContext: context,
              //   length: 4,
              //   controller: otpController,
              //   keyboardType: TextInputType.number,
              //   animationType: AnimationType.scale,
              //   enableActiveFill: true,
              //   pinTheme: PinTheme(
              //     shape: PinCodeFieldShape.box,
              //     borderRadius: BorderRadius.circular(15),
              //     fieldHeight: 55,
              //     fieldWidth: 55,
              //     activeFillColor: Colors.blue.shade50,
              //     inactiveFillColor: Colors.blue.shade50,
              //     selectedFillColor: Colors.white,
              //     inactiveColor: Colors.transparent,
              //     selectedColor: Colors.indigo,
              //     activeColor: Colors.indigo,
              //   ),
              //   onChanged: (value) {
              //     // You can handle OTP changes here
              //   },
              // ),

              PinCodeTextField(
                appContext: context,
                length: 4,
                controller: otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.scale,
                enableActiveFill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeFillColor: const Color(0xFFF3F8FB),
                  inactiveFillColor: const Color(0xFFF3F8FB),
                  selectedFillColor: Colors.white,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.indigo,
                  activeColor: Colors.indigo,
                ),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      otpController.text = "";
                    } else {
                      // Mask everything except last digit
                      String masked = "*" * (value.length - 1) + value.substring(value.length - 1);
                      otpController.value = TextEditingValue(
                        text: masked,
                        selection: TextSelection.collapsed(offset: masked.length),
                      );
                    }
                  });
                },
              ),


              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("01:23"),
                  Text(
                    "Resend OTP",
                    style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) =>  NewPasswordScreen()),
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
                      color: Colors.white,
                    ),
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
