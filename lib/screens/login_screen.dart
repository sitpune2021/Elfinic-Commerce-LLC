// // // import 'dart:convert';

// // // import 'package:elfinic_commerce_llc/screens/register_screen.dart';
// // // import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';

// // // import '../providers/AuthProvider.dart';
// // // import 'DashboardScreen.dart';
// // // import 'forgot_password.dart';

// // // class LoginScreen extends StatefulWidget {
// // //   const LoginScreen({super.key});

// // //   @override
// // //   LoginScreenState createState() => LoginScreenState();
// // // }

// // // class LoginScreenState extends State<LoginScreen>
// // //     with SingleTickerProviderStateMixin {
// // //   final _formKey = GlobalKey<FormState>();

// // //   final TextEditingController _emailController = TextEditingController();
// // //   final TextEditingController _passwordController = TextEditingController();

// // //   late TabController _tabController;

// // //   bool _isPasswordVisible = false;
// // //   bool _rememberMe = false;

// // //   bool _isLengthValid = false;
// // //   bool _hasUppercaseAndNumber = false;
// // //   bool _hasSpecialChar = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadSavedEmail();
// // //     _tabController = TabController(length: 2, vsync: this);
// // //   }

// // //   void _loadSavedEmail() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final savedEmail = prefs.getString("saved_email");
// // //     if (savedEmail != null) {
// // //       _emailController.text = savedEmail;
// // //       setState(() {
// // //         _rememberMe = true;
// // //       });
// // //     }
// // //   }

// // //   void _validatePassword(String value) {
// // //     _isLengthValid = value.length >= 6;
// // //     _hasUppercaseAndNumber =
// // //         value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[0-9]'));
// // //     _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final authProvider = Provider.of<AuthProvider>(context);

// // //     return Scaffold(
// // //       body: SingleChildScrollView(
// // //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
// // //         child: Form(
// // //           key: _formKey,
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.center,
// // //             children: [
// // //               const SizedBox(height: 10),

// // //               Image.asset(
// // //                 "assets/images/splash_screen_1.png",
// // //                 height: 120,
// // //                 width: 200,
// // //               ),
// // //               const SizedBox(height: 20),
// // //               const Align(
// // //                 alignment: Alignment.centerLeft,
// // //                 child: Text(
// // //                   "Login to your Account",
// // //                   style: TextStyle(
// // //                     fontSize: 22,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 5),
// // //               const Align(
// // //                 alignment: Alignment.centerLeft,
// // //                 child: Text(
// // //                   "Sign in to track your orders, manage your wishlist, and shop your favourite items anytime.",
// // //                   style: TextStyle(color: Colors.black54, fontSize: 14),
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 20),

// // //               // Email Field
// // //               const Align(
// // //                 alignment: Alignment.centerLeft,
// // //                 child: Text("Email",
// // //                     style: TextStyle(
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Colors.indigo,
// // //                     )),
// // //               ),
// // //               const SizedBox(height: 5),
// // //               TextFormField(
// // //                 controller: _emailController,
// // //                 keyboardType: TextInputType.emailAddress,
// // //                 decoration: InputDecoration(
// // //                   hintText: "Enter your email",
// // //                   filled: true,
// // //                   fillColor: Colors.blue.shade50,
// // //                   contentPadding: const EdgeInsets.symmetric(horizontal: 15),
// // //                   border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(30),
// // //                       borderSide: BorderSide.none),
// // //                 ),
// // //                 validator: (value) {
// // //                   if (value == null || value.isEmpty) {
// // //                     return 'Email is required';
// // //                   }
// // //                   if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
// // //                       .hasMatch(value)) {
// // //                     return 'Enter a valid email';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               const SizedBox(height: 15),

// // //               // Password Field
// // //               const Align(
// // //                 alignment: Alignment.centerLeft,
// // //                 child: Text("Password",
// // //                     style: TextStyle(
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Colors.indigo,
// // //                     )),
// // //               ),
// // //               const SizedBox(height: 5),
// // //               TextFormField(
// // //                 controller: _passwordController,
// // //                 obscureText: !_isPasswordVisible,
// // //                 decoration: InputDecoration(
// // //                   hintText: "Password",
// // //                   filled: true,
// // //                   fillColor: Colors.blue.shade50,
// // //                   contentPadding: const EdgeInsets.symmetric(horizontal: 15),
// // //                   border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(30),
// // //                       borderSide: BorderSide.none),
// // //                   suffixIcon: IconButton(
// // //                     icon: Icon(
// // //                         _isPasswordVisible
// // //                             ? Icons.visibility
// // //                             : Icons.visibility_off,
// // //                         color: Colors.grey),
// // //                     onPressed: () {
// // //                       setState(() {
// // //                         _isPasswordVisible = !_isPasswordVisible;
// // //                       });
// // //                     },
// // //                   ),
// // //                 ),
// // //                 onChanged: _validatePassword,
// // //                 validator: (value) {
// // //                   _validatePassword(value ?? '');
// // //                   if (value == null || value.isEmpty) {
// // //                     return 'Password is required';
// // //                   }
// // //                   if (!_isLengthValid ||
// // //                       !_hasUppercaseAndNumber ||
// // //                       !_hasSpecialChar) {
// // //                     return 'Password does not meet requirements';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               const SizedBox(height: 10),

// // //               // Remember Me & Forgot Password
// // //               Row(
// // //                 children: [
// // //                   Checkbox(
// // //                     value: _rememberMe,
// // //                     onChanged: (value) {
// // //                       setState(() {
// // //                         _rememberMe = value ?? false;
// // //                       });
// // //                     },
// // //                   ),
// // //                   const Text("Remember me"),
// // //                   const Spacer(),
// // //                   TextButton(
// // //                     onPressed: () {
// // //                       Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(
// // //                           builder: (context) => ForgotPasswordScreen(),
// // //                         ),
// // //                       );
// // //                     },
// // //                     child: const Text(
// // //                       "Forgot Password",
// // //                       style: TextStyle(color: Colors.orange),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 20),

// // //               // Login Button
// // //               ElevatedButton(
// // //                 style: ElevatedButton.styleFrom(
// // //                   minimumSize: const Size(double.infinity, 50),
// // //                   backgroundColor: Colors.indigo.shade900,
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(30),
// // //                   ),
// // //                 ),
// // //                 onPressed: authProvider.isLoading
// // //                     ? null
// // //                     : () async {
// // //                         if (!_formKey.currentState!.validate()) {
// // //                           ScaffoldMessenger.of(context).showSnackBar(
// // //                             const SnackBar(
// // //                                 content:
// // //                                     Text("Please fill all required fields")),
// // //                           );
// // //                           return;
// // //                         }

// // //                         await authProvider.login(
// // //                           _emailController.text.trim(),
// // //                           _passwordController.text.trim(),
// // //                         );

// // //                         if (authProvider.loginResponse != null &&
// // //                             authProvider.loginResponse!.status.toLowerCase() ==
// // //                                 "success" &&
// // //                             authProvider.loginResponse!.token != null) {
// // //                           final prefs = await SharedPreferences.getInstance();

// // //                           await prefs.setString(
// // //                               "auth_token", authProvider.loginResponse!.token!);

// // //                           if (authProvider.loginResponse!.user != null) {
// // //                             await prefs.setString(
// // //                               "user_data",
// // //                               jsonEncode(
// // //                                   authProvider.loginResponse!.user!.toJson()),
// // //                             );
// // //                           }

// // //                           if (_rememberMe) {
// // //                             await prefs.setString(
// // //                                 "saved_email", _emailController.text.trim());
// // //                           }
// // //                           if (!context.mounted) return;

// // //                           Navigator.pushReplacement(
// // //                             context,
// // //                             MaterialPageRoute(
// // //                               builder: (context) => const DashboardScreen(),
// // //                             ),
// // //                           );
// // //                         } else {
// // //                           if (!context.mounted) return;

// // //                           ScaffoldMessenger.of(context).showSnackBar(
// // //                             SnackBar(
// // //                                 content: Text(authProvider.errorMessage ??
// // //                                     "Login failed!!")),
// // //                           );
// // //                         }
// // //                       },
// // //                 child: authProvider.isLoading
// // //                     ? const CustomLoader()
// // //                     : const Text(
// // //                         "LOGIN",
// // //                         style: TextStyle(color: Colors.white, fontSize: 16),
// // //                       ),
// // //               ),

// // //               const SizedBox(height: 20),

// // //               // Sign Up
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.center,
// // //                 children: [
// // //                   const Text("Don’t have account yet? "),
// // //                   GestureDetector(
// // //                     onTap: () {
// // //                       Navigator.push(
// // //                         context,
// // //                         MaterialPageRoute(
// // //                           builder: (context) => RegisterScreen(),
// // //                         ),
// // //                       );
// // //                     },
// // //                     child: const Text(
// // //                       "Sign Up",
// // //                       style: TextStyle(color: Colors.orange),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 30),

// // //               // Divider
// // //               Row(
// // //                 children: const [
// // //                   Expanded(child: Divider()),
// // //                   Padding(
// // //                     padding: EdgeInsets.symmetric(horizontal: 8),
// // //                     child: Text("Or Log In with"),
// // //                   ),
// // //                   Expanded(child: Divider()),
// // //                 ],
// // //               ),
// // //               const SizedBox(height: 20),

// // //               // Social Login Buttons
// // //               Row(
// // //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // //                 children: [
// // //                   ElevatedButton(
// // //                     onPressed: () {},
// // //                     style: ElevatedButton.styleFrom(
// // //                       shape: const CircleBorder(),
// // //                       padding: const EdgeInsets.all(15),
// // //                       backgroundColor: Colors.blue,
// // //                     ),
// // //                     child: const Icon(Icons.facebook, color: Colors.white),
// // //                   ),
// // //                   ElevatedButton(
// // //                     onPressed: () {},
// // //                     style: ElevatedButton.styleFrom(
// // //                       shape: const CircleBorder(),
// // //                       padding: const EdgeInsets.all(15),
// // //                       backgroundColor: Colors.black,
// // //                     ),
// // //                     child: const Icon(Icons.apple, color: Colors.white),
// // //                   ),
// // //                   ElevatedButton(
// // //                     onPressed: () {},
// // //                     style: ElevatedButton.styleFrom(
// // //                       shape: const CircleBorder(),
// // //                       padding: const EdgeInsets.all(15),
// // //                       backgroundColor: Colors.white,
// // //                     ),
// // //                     child: ClipOval(
// // //                       child: Image.asset(
// // //                         "assets/icons/google.png",
// // //                         width: 22,
// // //                         height: 22,
// // //                         fit: BoxFit.cover,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'dart:async';
// // import 'dart:convert';

// // import 'package:elfinic_commerce_llc/screens/register_screen.dart';
// // import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import '../providers/AuthProvider.dart';
// // import 'DashboardScreen.dart';
// // import 'forgot_password.dart';

// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});

// //   @override
// //   LoginScreenState createState() => LoginScreenState();
// // }

// // class LoginScreenState extends State<LoginScreen>
// //     with SingleTickerProviderStateMixin {
// //   final _formKey = GlobalKey<FormState>();

// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();

// //   final TextEditingController _mobileController = TextEditingController();
// //   final TextEditingController _otpController = TextEditingController();

// //   late TabController _tabController;

// //   bool _isPasswordVisible = false;
// //   bool _rememberMe = false;

// //   bool _isLengthValid = false;
// //   bool _hasUppercaseAndNumber = false;
// //   bool _hasSpecialChar = false;

// //   /// OTP
// //   bool _otpSent = false;
// //   int _secondsRemaining = 60;
// //   Timer? _timer;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadSavedEmail();
// //     _tabController = TabController(length: 2, vsync: this);
// //   }

// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     _tabController.dispose();
// //     super.dispose();
// //   }

// //   void _loadSavedEmail() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final savedEmail = prefs.getString("saved_email");
// //     if (savedEmail != null) {
// //       _emailController.text = savedEmail;
// //       setState(() => _rememberMe = true);
// //     }
// //   }

// //   void _validatePassword(String value) {
// //     _isLengthValid = value.length >= 6;
// //     _hasUppercaseAndNumber =
// //         value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[0-9]'));
// //     _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
// //   }

// //   void _startOtpTimer() {
// //     setState(() {
// //       _otpSent = true;
// //       _secondsRemaining = 60;
// //     });

// //     _timer?.cancel();
// //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// //       if (_secondsRemaining == 0) {
// //         timer.cancel();
// //       } else {
// //         setState(() => _secondsRemaining--);
// //       }
// //     });
// //   }

// //   InputDecoration _decoration(String hint) {
// //     return InputDecoration(
// //       hintText: hint,
// //       filled: true,
// //       fillColor: Colors.blue.shade50,
// //       contentPadding: const EdgeInsets.symmetric(horizontal: 15),
// //       border: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(30),
// //         borderSide: BorderSide.none,
// //       ),
// //     );
// //   }

// //   ButtonStyle _buttonStyle() {
// //     return ElevatedButton.styleFrom(
// //       minimumSize: const Size(double.infinity, 50),
// //       backgroundColor: Colors.indigo.shade900,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(30),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final authProvider = Provider.of<AuthProvider>(context);

// //     return Scaffold(
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
// //         child: Form(
// //           key: _formKey,
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               Image.asset(
// //                 "assets/images/splash_screen_1.png",
// //                 height: 120,
// //                 width: 200,
// //               ),
// //               const SizedBox(height: 20),

// //               const Align(
// //                 alignment: Alignment.centerLeft,
// //                 child: Text(
// //                   "Login to your Account",
// //                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //               const SizedBox(height: 5),
// //               const Align(
// //                 alignment: Alignment.centerLeft,
// //                 child: Text(
// //                   "Sign in to track your orders, manage your wishlist, and shop your favourite items anytime.",
// //                   style: TextStyle(color: Colors.black54, fontSize: 14),
// //                 ),
// //               ),

// //               const SizedBox(height: 15),

// //               /// ================= TAB BAR =================
// //               Center(
// //                 child: TabBar(
// //                   controller: _tabController,
// //                   isScrollable: true,
// //                   labelColor: Colors.indigo,
// //                   unselectedLabelColor: Colors.grey,
// //                   indicatorColor: Colors.indigo,
// //                   tabs: const [
// //                     Tab(text: "Email Login"),
// //                     Tab(text: "Mobile OTP"),
// //                   ],
// //                 ),
// //               ),

// //               const SizedBox(height: 20),

// //               /// ================= TAB VIEW =================
// //               SizedBox(
// //                 height: 450,
// //                 child: TabBarView(
// //                   controller: _tabController,
// //                   children: [
// //                     /// EMAIL LOGIN TAB
// //                     _emailLoginUI(authProvider),

// //                     /// MOBILE OTP TAB
// //                     _mobileOtpUI(),
// //                   ],
// //                 ),
// //               ),

// //               /// ================= SHARED UI (NO REMOVAL) =================
// //               const SizedBox(height: 20),

// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const Text("Don’t have account yet? "),
// //                   GestureDetector(
// //                     onTap: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                             builder: (context) => RegisterScreen()),
// //                       );
// //                     },
// //                     child: const Text("Sign Up",
// //                         style: TextStyle(color: Colors.orange)),
// //                   ),
// //                 ],
// //               ),

// //               const SizedBox(height: 30),

// //               Row(
// //                 children: const [
// //                   Expanded(child: Divider()),
// //                   Padding(
// //                     padding: EdgeInsets.symmetric(horizontal: 8),
// //                     child: Text("Or Log In with"),
// //                   ),
// //                   Expanded(child: Divider()),
// //                 ],
// //               ),

// //               const SizedBox(height: 20),

// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //                 children: [
// //                   ElevatedButton(
// //                     onPressed: () {},
// //                     style: ElevatedButton.styleFrom(
// //                       shape: const CircleBorder(),
// //                       padding: const EdgeInsets.all(15),
// //                       backgroundColor: Colors.blue,
// //                     ),
// //                     child: const Icon(Icons.facebook, color: Colors.white),
// //                   ),
// //                   ElevatedButton(
// //                     onPressed: () {},
// //                     style: ElevatedButton.styleFrom(
// //                       shape: const CircleBorder(),
// //                       padding: const EdgeInsets.all(15),
// //                       backgroundColor: Colors.black,
// //                     ),
// //                     child: const Icon(Icons.apple, color: Colors.white),
// //                   ),
// //                   ElevatedButton(
// //                     onPressed: () {},
// //                     style: ElevatedButton.styleFrom(
// //                       shape: const CircleBorder(),
// //                       padding: const EdgeInsets.all(15),
// //                       backgroundColor: Colors.white,
// //                     ),
// //                     child: ClipOval(
// //                       child: Image.asset(
// //                         "assets/icons/google.png",
// //                         width: 22,
// //                         height: 22,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   /// ================= EMAIL LOGIN UI (UNCHANGED) =================
// //   Widget _emailLoginUI(AuthProvider authProvider) {
// //     return Column(
// //       children: [
// //         const Align(
// //           alignment: Alignment.centerLeft,
// //           child: Text("Email",
// //               style:
// //                   TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
// //         ),
// //         const SizedBox(height: 5),
// //         TextFormField(
// //           controller: _emailController,
// //           decoration: _decoration("Enter your email"),
// //         ),
// //         const SizedBox(height: 15),
// //         const Align(
// //           alignment: Alignment.centerLeft,
// //           child: Text("Password",
// //               style:
// //                   TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
// //         ),
// //         const SizedBox(height: 5),
// //         TextFormField(
// //           controller: _passwordController,
// //           obscureText: !_isPasswordVisible,
// //           decoration: _decoration("Password").copyWith(
// //             suffixIcon: IconButton(
// //               icon: Icon(
// //                   _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
// //               onPressed: () {
// //                 setState(() => _isPasswordVisible = !_isPasswordVisible);
// //               },
// //             ),
// //           ),
// //           onChanged: _validatePassword,
// //         ),
// //         Row(
// //           children: [
// //             Checkbox(
// //               value: _rememberMe,
// //               onChanged: (v) => setState(() => _rememberMe = v ?? false),
// //             ),
// //             const Text("Remember me"),
// //             const Spacer(),
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                       builder: (context) => ForgotPasswordScreen()),
// //                 );
// //               },
// //               child: const Text("Forgot Password",
// //                   style: TextStyle(color: Colors.orange)),
// //             ),
// //           ],
// //         ),
// //         ElevatedButton(
// //           style: _buttonStyle(),
// //           onPressed: authProvider.isLoading
// //     ? null
// //     : () async {
// //         if (!_formKey.currentState!.validate()) {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text("Please fill all required fields"),
// //             ),
// //           );
// //           return;
// //         }

// //         await authProvider.login(
// //           _emailController.text.trim(),
// //           _passwordController.text.trim(),
// //         );

// //         if (authProvider.loginResponse != null &&
// //             authProvider.loginResponse!.status.toLowerCase() == "success" &&
// //             authProvider.loginResponse!.token != null) {

// //           final prefs = await SharedPreferences.getInstance();

// //           await prefs.setString(
// //             "auth_token",
// //             authProvider.loginResponse!.token!,
// //           );

// //           if (authProvider.loginResponse!.user != null) {
// //             await prefs.setString(
// //               "user_data",
// //               jsonEncode(
// //                 authProvider.loginResponse!.user!.toJson(),
// //               ),
// //             );
// //           }

// //           if (_rememberMe) {
// //             await prefs.setString(
// //               "saved_email",
// //               _emailController.text.trim(),
// //             );
// //           }

// //           if (!context.mounted) return;

// //           Navigator.pushReplacement(
// //             context,
// //             MaterialPageRoute(
// //               builder: (context) => const DashboardScreen(),
// //             ),
// //           );
// //         } else {
// //           if (!context.mounted) return;

// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text(
// //                 authProvider.errorMessage ?? "Login failed!!",
// //               ),
// //             ),
// //           );
// //         }
// //       },

// //           child: authProvider.isLoading
// //               ? const CustomLoader()
// //               : const Text("LOGIN", style: TextStyle(color: Colors.white)),
// //         ),
// //       ],
// //     );
// //   }

// //   /// ================= MOBILE OTP UI =================
// //   Widget _mobileOtpUI() {
// //     return Column(
// //       children: [
// //         const Align(
// //           alignment: Alignment.centerLeft,
// //           child: Text("Mobile Number",
// //               style:
// //                   TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
// //         ),
// //         const SizedBox(height: 5),
// //         TextFormField(
// //           controller: _mobileController,
// //           keyboardType: TextInputType.phone,
// //           decoration: _decoration("Enter mobile number"),
// //         ),
// //         const SizedBox(height: 20),
// //         ElevatedButton(
// //           style: _buttonStyle(),
// //           onPressed: _otpSent ? null : _startOtpTimer,
// //           child: const Text("SEND OTP", style: TextStyle(color: Colors.white)),
// //         ),
// //         const SizedBox(height: 20),
// //         if (_otpSent)
// //           Column(
// //             children: [
// //               TextFormField(
// //                 controller: _otpController,
// //                 decoration: _decoration("Enter OTP"),
// //               ),
// //               const SizedBox(height: 10),
// //               Text(
// //                 _secondsRemaining > 0
// //                     ? "Resend OTP in $_secondsRemaining sec"
// //                     : "You can resend OTP",
// //                 style: const TextStyle(color: Colors.grey),
// //               ),
// //             ],
// //           ),
// //       ],
// //     );
// //   }
// // }
// import 'dart:async';

// import 'package:elfinic_commerce_llc/screens/register_screen.dart';
// import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../providers/AuthProvider.dart';
// import 'DashboardScreen.dart';
// import 'forgot_password.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   LoginScreenState createState() => LoginScreenState();
// }

// class LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   /// ================= FORM KEYS =================
//   final _emailFormKey = GlobalKey<FormState>();
//   final _mobileFormKey = GlobalKey<FormState>();

//   /// ================= CONTROLLERS =================
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();

//   late TabController _tabController;

//   bool _isPasswordVisible = false;
//   bool _rememberMe = false;

//   bool _isLengthValid = false;
//   bool _hasUppercaseAndNumber = false;
//   bool _hasSpecialChar = false;

//   /// ================= OTP STATE =================
//   bool _otpSent = false;
//   int _secondsRemaining = 60;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedEmail();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _loadSavedEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedEmail = prefs.getString("saved_email");
//     if (savedEmail != null) {
//       _emailController.text = savedEmail;
//       setState(() => _rememberMe = true);
//     }
//   }

//   void _validatePassword(String value) {
//     _isLengthValid = value.length >= 6;
//     _hasUppercaseAndNumber =
//         value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[0-9]'));
//     _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//   }

//   /// ================= OTP TIMER =================
//   void _startOtpTimer() {
//     FocusScope.of(context).unfocus();

//     setState(() {
//       _otpSent = true;
//       _secondsRemaining = 60;
//     });

//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsRemaining == 0) {
//         timer.cancel();
//       } else {
//         setState(() => _secondsRemaining--);
//       }
//     });
//   }

//   /// ================= UI HELPERS =================
//   InputDecoration _decoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       filled: true,
//       fillColor: Colors.blue.shade50,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 15),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(30),
//         borderSide: BorderSide.none,
//       ),
//     );
//   }

//   ButtonStyle _buttonStyle() {
//     return ElevatedButton.styleFrom(
//       minimumSize: const Size(double.infinity, 50),
//       backgroundColor: Colors.indigo.shade900,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(30),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               "assets/images/splash_screen_1.png",
//               height: 120,
//               width: 200,
//             ),
//             const SizedBox(height: 20),

//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Login to your Account",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 5),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Sign in to track your orders, manage your wishlist, and shop your favourite items anytime.",
//                 style: TextStyle(color: Colors.black54, fontSize: 14),
//               ),
//             ),

//             const SizedBox(height: 15),

//             /// ================= TAB BAR =================
//             Center(
//               child: TabBar(
//                 controller: _tabController,
//                 isScrollable: true,
//                 labelColor: Colors.indigo,
//                 unselectedLabelColor: Colors.grey,
//                 indicatorColor: Colors.indigo,
//                 tabs: const [
//                   Tab(text: "Email Login"),
//                   Tab(text: "Mobile OTP"),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// ================= TAB VIEW =================
//             SizedBox(
//               height: 460,
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   /// EMAIL TAB
//                   Form(
//                     key: _emailFormKey,
//                     child: _emailLoginUI(authProvider),
//                   ),

//                   /// MOBILE TAB
//                   Form(
//                     key: _mobileFormKey,
//                     child: _mobileOtpUI(),
//                   ),
//                 ],
//               ),
//             ),

//             /// ================= SHARED UI =================
//             const SizedBox(height: 20),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text("Don’t have account yet? "),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => RegisterScreen()),
//                     );
//                   },
//                   child: const Text(
//                     "Sign Up",
//                     style: TextStyle(color: Colors.orange),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             Row(
//               children: const [
//                 Expanded(child: Divider()),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 8),
//                   child: Text("Or Log In with"),
//                 ),
//                 Expanded(child: Divider()),
//               ],
//             ),

//             const SizedBox(height: 20),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(15),
//                     backgroundColor: Colors.blue,
//                   ),
//                   child: const Icon(Icons.facebook, color: Colors.white),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(15),
//                     backgroundColor: Colors.black,
//                   ),
//                   child: const Icon(Icons.apple, color: Colors.white),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     shape: const CircleBorder(),
//                     padding: const EdgeInsets.all(15),
//                     backgroundColor: Colors.white,
//                   ),
//                   child: ClipOval(
//                     child: Image.asset(
//                       "assets/icons/google.png",
//                       width: 22,
//                       height: 22,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ================= EMAIL LOGIN =================
//   Widget _emailLoginUI(AuthProvider authProvider) {
//     return Column(
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text("Email",
//               style:
//                   TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
//         ),
//         const SizedBox(height: 5),
//         TextFormField(
//           controller: _emailController,
//           decoration: _decoration("Enter your email"),
//           validator: (value) {
//             if (value == null || value.isEmpty) return "Email required";
//             return null;
//           },
//         ),
//         const SizedBox(height: 15),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text("Password",
//               style:
//                   TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
//         ),
//         const SizedBox(height: 5),
//         TextFormField(
//           controller: _passwordController,
//           obscureText: !_isPasswordVisible,
//           decoration: _decoration("Password").copyWith(
//             suffixIcon: IconButton(
//               icon: Icon(
//                   _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
//               onPressed: () {
//                 setState(() => _isPasswordVisible = !_isPasswordVisible);
//               },
//             ),
//           ),
//           onChanged: _validatePassword,
//         ),
//         Row(
//           children: [
//             Checkbox(
//               value: _rememberMe,
//               onChanged: (v) => setState(() => _rememberMe = v ?? false),
//             ),
//             const Text("Remember me"),
//             const Spacer(),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => ForgotPasswordScreen()),
//                 );
//               },
//               child: const Text(
//                 "Forgot Password",
//                 style: TextStyle(color: Colors.orange),
//               ),
//             ),
//           ],
//         ),
//         ElevatedButton(
//           style: _buttonStyle(),
//           onPressed: authProvider.isLoading
//               ? null
//               : () async {
//                   if (!_emailFormKey.currentState!.validate()) return;

//                   await authProvider.login(
//                     _emailController.text.trim(),
//                     _passwordController.text.trim(),
//                   );

//                   if (authProvider.loginResponse?.status.toLowerCase() ==
//                       "success") {
//                     final prefs = await SharedPreferences.getInstance();
//                     await prefs.setString(
//                         "auth_token", authProvider.loginResponse!.token!);

//                     if (!context.mounted) return;
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => const DashboardScreen(),
//                       ),
//                     );
//                   }
//                 },
//           child: authProvider.isLoading
//               ? const CustomLoader()
//               : const Text(
//                   "LOGIN",
//                   style: TextStyle(color: Colors.white),
//                 ),
//         ),
//       ],
//     );
//   }

//   /// ================= MOBILE OTP =================
//   Widget _mobileOtpUI() {
//     return Column(
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text("Mobile Number",
//               style:
//                   TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
//         ),
//         const SizedBox(height: 5),
//         TextFormField(
//           controller: _mobileController,
//           decoration: _decoration("Enter mobile number"),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return "Mobile number required";
//             }
//             return null;
//           },
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           style: _buttonStyle(),
//           onPressed: () {
//             if (_mobileFormKey.currentState!.validate()) {
//               _startOtpTimer();
//             }
//           },
//           child: const Text("SEND OTP", style: TextStyle(color: Colors.white)),
//         ),
//         const SizedBox(height: 20),
//         if (_otpSent)
//           Column(
//             children: [
//               TextFormField(
//                 controller: _otpController,
//                 decoration: _decoration("Enter OTP"),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 _secondsRemaining > 0
//                     ? "Resend OTP in $_secondsRemaining sec"
//                     : "You can resend OTP",
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//       ],
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';

import 'package:elfinic_commerce_llc/screens/register_screen.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/AuthProvider.dart';
import 'DashboardScreen.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  /// ================= FORM KEYS =================
  final _emailFormKey = GlobalKey<FormState>();
  final _mobileFormKey = GlobalKey<FormState>();

  /// ================= CONTROLLERS =================
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final FocusNode _otpFocusNode = FocusNode();

  late TabController _tabController;

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  bool _isLengthValid = false;
  bool _hasUppercaseAndNumber = false;
  bool _hasSpecialChar = false;

  /// ================= OTP STATE =================
  bool _otpSent = false;
  bool _otpVerified = false;
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString("saved_email");
    if (savedEmail != null) {
      _emailController.text = savedEmail;
      setState(() => _rememberMe = true);
    }
  }

  void _validatePassword(String value) {
    _isLengthValid = value.length >= 6;
    _hasUppercaseAndNumber =
        value.contains(RegExp(r'[A-Z]')) && value.contains(RegExp(r'[0-9]'));
    _hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  /// ================= OTP TIMER =================
  void _startOtpTimer() {
    FocusScope.of(context).unfocus();

    setState(() {
      _otpSent = true;
      _otpVerified = false;
      _secondsRemaining = 60;
      _otpController.clear();
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(_otpFocusNode);
    });
  }

  /// ================= VERIFY OTP (AUTO LOGIN) =================
  void _verifyOtpAndLogin() async {
    if (_otpController.text.length < 4) return;

    setState(() => _otpVerified = true);

    // 🔐 AUTO LOGIN (UI ONLY)
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  /// ================= UI HELPERS =================
  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.blue.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      backgroundColor: Colors.indigo.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          children: [
            Image.asset(
              "assets/images/splash_screen_1.png",
              height: 120,
              width: 200,
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Login to your Account",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Sign in to track your orders, manage your wishlist, and shop your favourite items anytime.",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            const SizedBox(height: 15),

            TabBar(
              controller: _tabController,
              isScrollable: false, // 👈 IMPORTANT
              labelColor: Colors.indigo,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.indigo,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: "Email Login"),
                Tab(text: "Mobile Number Login"),
              ],
            ),

            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Form(
                    key: _emailFormKey,
                    child: _emailLoginUI(authProvider),
                  ),
                  Form(
                    key: _mobileFormKey,
                    child: _mobileOtpUI(),
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don’t have account yet? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("Or Log In with"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Icon(Icons.facebook, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                    backgroundColor: Colors.black,
                  ),
                  child: const Icon(Icons.apple, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(15),
                    backgroundColor: Colors.white,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/icons/google.png",
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ================= EMAIL LOGIN =================
  Widget _emailLoginUI(AuthProvider authProvider) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Email",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _emailController,
          decoration: _decoration("Enter your email"),
          validator: (value) =>
              value == null || value.isEmpty ? "Email required" : null,
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerLeft,
          child: Text("Password",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: _decoration("Password").copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() => _isPasswordVisible = !_isPasswordVisible);
              },
            ),
          ),
          onChanged: _validatePassword,
        ),
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
            ),
            const Text("Remember me"),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen()),
                );
              },
              child: const Text(
                "Forgot Password",
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
        ElevatedButton(
          style: _buttonStyle(),
          onPressed: authProvider.isLoading
              ? null
              : () async {
                  if (!_emailFormKey.currentState!.validate()) return;

                  await authProvider.login(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );

                  if (authProvider.loginResponse?.status.toLowerCase() ==
                      "success") {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(
                        "auth_token", authProvider.loginResponse!.token!);

                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  }
                },
          child: authProvider.isLoading
              ? const CustomLoader()
              : const Text(
                  "LOGIN",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  /// ================= MOBILE OTP =================
  // Widget _mobileOtpUI() {
  //   return Column(
  //     children: [
  //       /// MOBILE NUMBER
  //       Align(
  //         alignment: Alignment.centerLeft,
  //         child: Text(
  //           "Mobile Number",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.indigo,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 5),
  //       IntlPhoneField(
  //         controller: _mobileController,
  //         decoration: InputDecoration(
  //           hintText: "Mobile Number",
  //           filled: true,
  //           counterText: "",
  //           fillColor: Colors.blue.shade50,
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(30),
  //             borderSide: BorderSide.none,
  //           ),
  //           contentPadding: const EdgeInsets.symmetric(horizontal: 15),
  //         ),
  //         initialCountryCode: 'IN',
  //       ),

  //       const SizedBox(height: 20),

  //       /// OTP FIELD (SHOW ONLY AFTER OTP SENT)
  //       if (_otpSent) ...[
  //         Align(
  //           alignment: Alignment.centerLeft,
  //           child: Text(
  //             "OTP",
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               color: Colors.indigo,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 5),
  //         TextFormField(
  //           controller: _otpController,
  //           focusNode: _otpFocusNode,
  //           keyboardType: TextInputType.number,
  //           decoration: _decoration("Enter OTP"),
  //           onChanged: (_) => setState(() {}),
  //         ),
  //         const SizedBox(height: 10),
  //         Text(
  //           _secondsRemaining > 0
  //               ? "Resend OTP in $_secondsRemaining sec"
  //               : "Didn’t receive OTP?",
  //           style: const TextStyle(color: Colors.grey),
  //         ),
  //         TextButton(
  //           onPressed: _secondsRemaining > 0 ? null : _startOtpTimer,
  //           child: const Text("Resend OTP"),
  //         ),
  //         const SizedBox(height: 20),
  //       ],

  //       /// SINGLE BUTTON (SEND OTP / VERIFY & LOGIN)
  //       ElevatedButton(
  //         style: _buttonStyle(),
  //         onPressed: () {
  //           if (!_otpSent) {
  //             if (_mobileFormKey.currentState!.validate()) {
  //               _startOtpTimer();
  //             }
  //           } else {
  //             _verifyOtpAndLogin();
  //           }
  //         },
  //         child: Text(
  //           _otpSent ? "VERIFY & LOGIN" : "SEND OTP",
  //           style: const TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _mobileOtpUI() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        void showError(String message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }

        void showSuccess(String message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        }

        return Column(
          children: [
            /// ================= MOBILE NUMBER =================
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Mobile Number",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 5),
            IntlPhoneField(
              controller: _mobileController,
              decoration: InputDecoration(
                hintText: "Mobile Number",
                filled: true,
                counterText: "",
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
              initialCountryCode: 'IN',
            ),

            const SizedBox(height: 20),

            /// ================= OTP FIELD =================
            if (_otpSent) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "OTP",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _decoration("Enter 6 digit OTP").copyWith(
                  counterText: "",
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              Text(
                _secondsRemaining > 0
                    ? "Resend OTP in $_secondsRemaining sec"
                    : "Didn’t receive OTP?",
                style: const TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: _secondsRemaining > 0
                    ? null
                    : () async {
                        await authProvider
                            .sendOtp(_mobileController.text.trim());
                        if (authProvider.errorMessage != null) {
                          showError(authProvider.errorMessage!);
                        } else {
                          showSuccess("OTP sent successfully");
                          _startOtpTimer();
                        }
                      },
                child: const Text("Resend OTP"),
              ),
              const SizedBox(height: 20),
            ],

            /// ================= BUTTON =================
            ElevatedButton(
              style: _buttonStyle(),
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      final mobile = _mobileController.text.trim();

                      /// ---------- SEND OTP ----------
                      if (!_otpSent) {
                        if (mobile.length < 10) {
                          showError("Please enter a valid mobile number");
                          return;
                        }

                        await authProvider.sendOtp(mobile);

                        if (authProvider.errorMessage != null) {
                          showError(authProvider.errorMessage!);
                        } else {
                          showSuccess("OTP sent successfully");
                          _startOtpTimer();
                        }
                      }

                      /// ---------- VERIFY OTP ----------
                      else {
                        final otp = _otpController.text.trim();

                        if (otp.length != 6) {
                          showError("Please enter a valid 6 digit OTP");
                          return;
                        }

                        await authProvider.verifyOtpLogin(mobile, otp);

                        if (authProvider.errorMessage != null) {
                          showError(authProvider.errorMessage!);
                          return;
                        }

                        if (authProvider.loginResponse?.status.toLowerCase() ==
                            "success") {
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                          );
                        }
                      }
                    },
              child: authProvider.isLoading
                  ? const CustomLoader()
                  : Text(
                      _otpSent ? "VERIFY & LOGIN" : "SEND OTP",
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ],
        );
      },
    );
  }
}
