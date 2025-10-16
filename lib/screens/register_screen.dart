import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';


import '../providers/RegisterProvider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _isPasswordVisible = false;
  bool _obscureConfirmPassword = true;

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegisterProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                "Welcome to Elfinic.com",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Enter your details to register",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 25),

              // Full Name
              _buildLabel("Full Name"),
              TextField(
                controller: nameController,
                decoration: _inputDecoration("Enter your full name"),
              ),
              const SizedBox(height: 20),

              // Username
              _buildLabel("Username"),
              TextField(
                controller: usernameController,
                decoration: _inputDecoration("Choose a username"),
              ),
              const SizedBox(height: 20),

              // Email
              _buildLabel("Email"),
              TextField(
                controller: emailController,
                decoration: _inputDecoration("Enter your email"),
              ),
              const SizedBox(height: 20),

              // Mobile Number
              _buildLabel("Mobile Number"),
              IntlPhoneField(
                controller: mobileController,
                initialCountryCode: 'IN',
                decoration: _inputDecoration("Enter your mobile number"),
              ),
              const SizedBox(height: 20),

              // OTP
              _buildLabel("Enter OTP"),
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
                  activeColor: Colors.green,
                ),
                onChanged: (value) {},
              ),
              const SizedBox(height: 20),

              // Password
              _buildLabel("Password"),
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                onChanged: _validatePassword,
                decoration: _inputDecoration("Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                ),
              ),
              _buildPasswordChecks(),
              const SizedBox(height: 20),

              // Confirm Password
              _buildLabel("Confirm Password"),
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: _inputDecoration("Confirm Password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                    if (nameController.text.isEmpty ||
                        usernameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        mobileController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please fill all fields")),
                      );
                      return;
                    }
                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Passwords do not match")),
                      );
                      return;
                    }

                    await provider.registerUser(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      mobile: mobileController.text.trim(),
                      username: usernameController.text.trim(),
                      password: passwordController.text.trim(),
                      passwordConfirmation:
                      confirmPasswordController.text.trim(),
                    );

                    if (provider.registerResponse?.status == "success") {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Registration Successful! Please login.")),
                      );

                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage ?? "Registration failed"),
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CONTINUE",
                      style:
                      TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style:
      const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.blue.shade50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  );

  Widget _buildPasswordChecks() {
    return Column(
      children: [
        _passwordCheck(_isLengthValid, "Password Must Be At Least 8 Characters"),
        _passwordCheck(
            _hasUppercaseAndNumber, "At Least One Uppercase & One Number"),
        _passwordCheck(_hasSpecialChar, "At Least One Special Character"),
      ],
    );
  }

  Widget _passwordCheck(bool valid, String text) {
    return Row(
      children: [
        Icon(valid ? Icons.check_circle : Icons.cancel,
            color: valid ? Colors.green : Colors.red, size: 18),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}


// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({Key? key}) : super(key: key);
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//
//   bool _isPasswordVisible = false;
//   bool _obscureConfirmPassword = true;
//
//   String phoneNumber = "";
//
//   // Password validation flags
//   bool _isLengthValid = false;
//   bool _hasUppercaseAndNumber = false;
//   bool _hasSpecialChar = false;
//
//   void _validatePassword(String password) {
//     setState(() {
//       _isLengthValid = password.length >= 8;
//       _hasUppercaseAndNumber = RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(password);
//       _hasSpecialChar = RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Back Button
//               IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.indigo),
//                 onPressed: () => Navigator.pop(context),
//               ),
//
//               const SizedBox(height: 10),
//
//               // Title
//               const Text(
//                 "Welcome to Elfinic.com",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               const Text(
//                 "Enter your details to register",
//                 style: TextStyle(color: Colors.black54, fontSize: 16),
//               ),
//               const SizedBox(height: 25),
//
//               // Email
//               // const Text(
//               //   "Email",
//               //   style: TextStyle(fontWeight: FontWeight.bold),
//               // ),
//               // Email Field
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Email",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.indigo,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               TextField(
//                 controller: emailController,
//                 decoration: InputDecoration(
//                   hintText: "Enter your email",
//                   filled: true,
//                   fillColor: Colors.blue.shade50,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//
//
//               const SizedBox(height: 20),
//
//
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Mobile Number",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.indigo,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 5),
//
//               IntlPhoneField(
//                 controller: mobileController,
//                 decoration: InputDecoration(
//                   hintText: "Enter your mobile number",
//                   filled: true,
//                   fillColor: Colors.blue.shade50,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 initialCountryCode: 'IN', // Default country
//                 dropdownDecoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//               const SizedBox(height: 5),
//               // const Text(
//               //   "Enter Mobile Number",
//               //   style: TextStyle(color: Colors.red),
//               // ),
//
//               const SizedBox(height: 20),
//
//               // OTP
//               const Text(
//                 "Enter OTP",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//
//               PinCodeTextField(
//                 appContext: context,
//                 length: 4,
//                 controller: otpController,
//                 keyboardType: TextInputType.number,
//                 animationType: AnimationType.scale,
//                 enableActiveFill: true,
//                 pinTheme: PinTheme(
//                   shape: PinCodeFieldShape.box,
//                   borderRadius: BorderRadius.circular(10),
//                   fieldHeight: 50,
//                   fieldWidth: 50,
//                   activeFillColor: const Color(0xFFF3F8FB),
//                   inactiveFillColor: const Color(0xFFF3F8FB),
//                   selectedFillColor: Colors.white,
//                   inactiveColor: Colors.grey,
//                   selectedColor: Colors.indigo,
//                   activeColor: Colors.green,
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     if (value.isEmpty) {
//                       otpController.text = "";
//                     } else {
//                       // Mask everything except last digit
//                       String masked = "*" * (value.length - 1) + value.substring(value.length - 1);
//                       otpController.value = TextEditingValue(
//                         text: masked,
//                         selection: TextSelection.collapsed(offset: masked.length),
//                       );
//                     }
//                   });
//                 },
//               ),
//
//
//
//               const SizedBox(height: 5),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text("01:23"),
//                   Text(
//                     "Resend OTP",
//                     style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 20),
//
//               // Password
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Password",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.indigo,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 5),
//
//               TextField(
//                 controller: passwordController,
//                 obscureText: !_isPasswordVisible,
//                 onChanged: _validatePassword,
//                 decoration: InputDecoration(
//                   hintText: "Password",
//                   filled: true,
//                   fillColor: Colors.blue.shade50,
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _isPasswordVisible = !_isPasswordVisible;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Icon(
//                     _isLengthValid ? Icons.check_circle : Icons.cancel,
//                     color: _isLengthValid ? Colors.green : Colors.red,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 5),
//                   const Text("Password Must Be At Least 8 Characters Long"),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Icon(
//                     _hasUppercaseAndNumber ? Icons.check_circle : Icons.cancel,
//                     color: _hasUppercaseAndNumber ? Colors.green : Colors.red,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 5),
//                   const Text("At Least One Uppercase Letter and One Number"),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Icon(
//                     _hasSpecialChar ? Icons.check_circle : Icons.cancel,
//                     color: _hasSpecialChar ? Colors.green : Colors.red,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 5),
//                   const Text("At Least One Special Character"),
//                 ],
//               ),
//
//
//               const SizedBox(height: 20),
//
//               // Confirm Password
//               const Text(
//                 "Confirm Password",
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 5),
//               TextField(
//                 controller: confirmPasswordController,
//                 obscureText: _obscureConfirmPassword,
//                 decoration: InputDecoration(
//                   hintText: "Password",
//                   filled: true,
//                   fillColor:Colors.blue.shade50,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                         _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
//                     onPressed: () {
//                       setState(() {
//                         _obscureConfirmPassword = !_obscureConfirmPassword;
//                       });
//                     },
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//
//               // Continue Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.indigo[900],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   child: const Text(
//                     "CONTINUE",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
