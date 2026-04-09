
import 'dart:async';

import 'package:elfinic_commerce_llc/screens/privacy_policy_screen.dart';
import 'package:elfinic_commerce_llc/screens/register_screen.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/AuthProvider.dart';
import 'DashboardScreen.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {

  final bool fromAddToCart; // 👈 ADD THIS
  const LoginScreen({super.key,
  this.fromAddToCart = false, // 👈 DEFAULT VALUE
  });

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
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  /// ================= OTP STATE =================
  bool _otpSent = false;
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

  void _validatePassword(String value) {}

  /// ================= OTP TIMER =================
  void _startOtpTimer() {
    FocusScope.of(context).unfocus();

    setState(() {
      _otpSent = true;
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

    bool _agreeToMarketing = false;
    return Scaffold(
      backgroundColor: Colors.white,
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
              height: 320,
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
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _agreeToTerms,

                    activeColor: Colors.indigo,
                    onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                    title: Text.rich(
                      TextSpan(
                        style: AppTextStyles.normal,
                        children: [
                          const TextSpan(text: "I agree to the "),

                          TextSpan(
                            text: "Terms & Conditions",
                            style: AppTextStyles.link,
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),

                          const TextSpan(text: ", "),

                          TextSpan(
                            text: "Privacy Policy",
                            style: AppTextStyles.link,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacyPolicyScreen(),
                                  ),
                                );
                              },
                          ),

                          const TextSpan(text: ", "),

                          TextSpan(
                            text: "Return Policy",
                            style: AppTextStyles.link,
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),

                          const TextSpan(text: " and "),

                          TextSpan(
                            text: "Contact Seller",
                            style: AppTextStyles.link,
                            recognizer: TapGestureRecognizer()..onTap = () {},
                          ),
                        ],
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

               /*   CheckboxListTile(
                    value: _agreeToMarketing,
                    onChanged: (v) =>
                        setState(() => _agreeToMarketing = v ?? false),
                    title: const Text(
                      "Send me marketing communications via email and SMS",
                      style: AppTextStyles.checkboxText,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),*/
                ],
              ),
            ),
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // ElevatedButton(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     shape: const CircleBorder(),
                //     padding: const EdgeInsets.all(15),
                //     backgroundColor: Colors.blue,
                //   ),
                //   child: const Icon(Icons.facebook, color: Colors.white),
                // ),
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


            /// ✅ CHECK TERMS FIRST
            if (!_agreeToTerms) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please accept Terms & Conditions"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }


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

                    // if (!mounted) return;
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => const DashboardScreen(),
                    //   ),
                    // );
                    if (widget.fromAddToCart) {
                      Navigator.pop(context); // 🔥 go back to product page
                    } else {
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
              : const Text(
                  "LOGIN",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  /// ================= MOBILE OTP =================

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

                /// ✅ CHECK TERMS FIRST
                if (!_agreeToTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please accept Terms & Conditions"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

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

                          if (widget.fromAddToCart) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            );
                          }
                         /* if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                          );*/
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

class AppTextStyles {
  static const TextStyle normal = TextStyle(
    fontSize: 13,
    color: Colors.black87,
    height: 1.4,
  );

  static const TextStyle link = TextStyle(
    fontSize: 13,
    color: Colors.indigo,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );

  static const TextStyle checkboxText = TextStyle(
    fontSize: 13,
    color: Colors.black87,
  );
}
