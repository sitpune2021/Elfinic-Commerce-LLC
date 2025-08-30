import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';


import 'forgot_password_otp.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }
//
// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final TextEditingController emailController = TextEditingController(text: "goneshubham@gmail.com");
//   final TextEditingController mobileController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Back button
//               IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.indigo),
//                 onPressed: () => Navigator.pop(context),
//               ),
//
//               const SizedBox(height: 10),
//
//               const Text(
//                 "Forgot Password",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               const Text(
//                 "Select option to reset password",
//                 style: TextStyle(color: Colors.black54, fontSize: 16),
//               ),
//               const SizedBox(height: 25),
//
//               const Text("Via Email",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.indigo,
//                   )),
//               const SizedBox(height: 5),
//
//               TextField(
//                 controller: emailController,
//                 readOnly: true,
//                 decoration: InputDecoration(
//                   filled: true,
//                   fillColor: Colors.blue.shade50,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               const Text("Via Mobile Number",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.indigo,
//                   )),
//               const SizedBox(height: 5),
//
//               IntlPhoneField(
//                 controller: mobileController,
//                 decoration: InputDecoration(
//                   hintText: "Mobile Number",
//                   filled: true,
//                   fillColor: Colors.blue.shade50,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(30),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//                 ),
//                 initialCountryCode: 'IN',
//               ),
//
//               const Spacer(),
//
//               // Continue Button
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ForgotPasswordOTPScreen()),
//                     );
//                   },
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
