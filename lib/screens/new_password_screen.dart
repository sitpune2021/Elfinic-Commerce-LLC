// import 'package:flutter/material.dart';

// import 'login_screen.dart';

// class NewPasswordScreen extends StatefulWidget {
//   const NewPasswordScreen({super.key});

//   @override
//   State<NewPasswordScreen> createState() => _NewPasswordScreenState();
// }

// class _NewPasswordScreenState extends State<NewPasswordScreen> {
//   final TextEditingController newPasswordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   bool rememberMe = false;
//   bool obscureNewPassword = true;
//   bool obscureConfirmPassword = true;

//   // Password validation flags
//   bool _isLengthValid = false;
//   bool _hasUppercaseAndNumber = false;
//   bool _hasSpecialChar = false;

//   void _validatePassword(String password) {
//     setState(() {
//       _isLengthValid = password.length >= 8;
//       _hasUppercaseAndNumber = RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(password);
//       _hasSpecialChar = RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Back Button
//                 IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.indigo),
//                   onPressed: () => Navigator.pop(context),
//                 ),

//                 const SizedBox(height: 10),

//                 // Title
//                 const Text(
//                   "Create your new Password",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 25),

//                 // New Password
//                 const Text(
//                   "Enter New Password",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.indigo,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 TextField(
//                   controller: newPasswordController,
//                   obscureText: !obscureNewPassword,
//                   onChanged: _validatePassword,
//                   decoration: InputDecoration(
//                     hintText: "Password",
//                     filled: true,
//                     fillColor: Colors.blue.shade50,
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         obscureNewPassword ? Icons.visibility : Icons.visibility_off,
//                         color: Colors.grey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           obscureNewPassword = !obscureNewPassword;
//                         });
//                       },
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Icon(
//                       _isLengthValid ? Icons.check_circle : Icons.cancel,
//                       color: _isLengthValid ? Colors.green : Colors.red,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 5),
//                     const Text("Password Must Be At Least 8 Characters Long"),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Icon(
//                       _hasUppercaseAndNumber ? Icons.check_circle : Icons.cancel,
//                       color: _hasUppercaseAndNumber ? Colors.green : Colors.red,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 5),
//                     const Text("At Least One Uppercase Letter and One Number"),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Icon(
//                       _hasSpecialChar ? Icons.check_circle : Icons.cancel,
//                       color: _hasSpecialChar ? Colors.green : Colors.red,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 5),
//                     const Text("At Least One Special Character"),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // Confirm Password
//                 const Text(
//                   "Confirm Password",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.indigo,
//                   ),
//                 ),
//                 const SizedBox(height: 5),

//                 TextField(
//                   controller: confirmPasswordController,
//                   obscureText: obscureConfirmPassword,
//                   decoration: InputDecoration(
//                     hintText: "Password",
//                     filled: true,
//                     fillColor: Colors.blue.shade50,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
//                         color: Colors.grey,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           obscureConfirmPassword = !obscureConfirmPassword;
//                         });
//                       },
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 15),

//                 // Remember Me Checkbox
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: rememberMe,
//                       activeColor: Colors.indigo,
//                       onChanged: (value) {
//                         setState(() {
//                           rememberMe = value ?? false;
//                         });
//                       },
//                     ),
//                     const Text("Remember me"),
//                   ],
//                 ),

//                 // const Spacer(),
//                 const SizedBox(height: 30), // or any height you need

//                 // Confirm Button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Handle confirm action
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) =>  LoginScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.indigo[900],
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                     ),
//                     child: const Text(
//                       "CONFIRM",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:elfinic_commerce_llc/providers/forgot%20password/forgot_password_provider.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  final String mobile;
  final String otp;

  const NewPasswordScreen({
    super.key,
    required this.mobile,
    required this.otp,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController newPasswordController = TextEditingController();

  bool obscurePassword = true;

  // Password validation flags
  bool _isLengthValid = false;
  bool _hasUppercaseAndNumber = false;
  bool _hasSpecialChar = false;

  void _validatePassword(String password) {
    setState(() {
      _isLengthValid = password.length >= 8;
      _hasUppercaseAndNumber =
          RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(password);
      _hasSpecialChar =
          RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password);
    });
  }

  bool get _isPasswordValid =>
      _isLengthValid && _hasUppercaseAndNumber && _hasSpecialChar;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgotPasswordProvider>();

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
                "Set New Password",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              const Text(
                "New Password",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: newPasswordController,
                obscureText: obscurePassword,
                onChanged: _validatePassword,
                decoration: InputDecoration(
                  hintText: "Enter password",
                  filled: true,
                  fillColor: Colors.blue.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildRule("At least 8 characters", _isLengthValid),
              _buildRule("One uppercase & one number", _hasUppercaseAndNumber),
              _buildRule("One special character", _hasSpecialChar),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          if (!_isPasswordValid) {
                            _showMessage(
                              "Password does not meet requirements",
                            );
                            return;
                          }

                          final success =
                              await provider.verifyOtpAndSetPassword(
                            mobile: widget.mobile,
                            otp: widget.otp,
                            password: newPasswordController.text.trim(),
                          );

                          if (success && context.mounted) {
                            _showMessage("Password updated successfully");

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          } else if (provider.errorMessage != null) {
                            _showMessage(provider.errorMessage!);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: provider.isLoading
                      ? const CustomLoader()
                      : const Text(
                          "CONFIRM",
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

  Widget _buildRule(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 5),
        Text(text),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
