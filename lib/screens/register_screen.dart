import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';


import '../providers/RegisterProvider.dart';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
  final TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _obscureConfirmPassword = true;

  // Password validation flags
  bool _isLengthValid = false;
  bool _hasUppercaseAndNumber = false;
  bool _hasSpecialChar = false;

  // Validation error messages
  String? _nameError;
  String? _usernameError;
  String? _emailError;
  String? _mobileError;
  String? _otpError;
  String? _passwordError;
  String? _confirmPasswordError;

  void _validatePassword(String password) {
    setState(() {
      _isLengthValid = password.length >= 8;
      _hasUppercaseAndNumber = RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(password);
      _hasSpecialChar = RegExp(r'(?=.*[!@#$%^&*(),.?":{}|<>])').hasMatch(password);
    });
  }

  void _clearAllErrors() {
    setState(() {
      _nameError = null;
      _usernameError = null;
      _emailError = null;
      _mobileError = null;
      _otpError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  bool _validateForm() {
    _clearAllErrors();
    bool isValid = true;

    // Name validation
    if (nameController.text.isEmpty) {
      setState(() => _nameError = "Full name is required");
      isValid = false;
    } else if (nameController.text.length < 2) {
      setState(() => _nameError = "Name must be at least 2 characters");
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(nameController.text)) {
      setState(() => _nameError = "Name can only contain letters and spaces");
      isValid = false;
    }

    // Username validation
    if (usernameController.text.isEmpty) {
      setState(() => _usernameError = "Username is required");
      isValid = false;
    } else if (usernameController.text.length < 3) {
      setState(() => _usernameError = "Username must be at least 3 characters");
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usernameController.text)) {
      setState(() => _usernameError = "Username can only contain letters, numbers and underscore");
      isValid = false;
    }

    // Email validation
    if (emailController.text.isEmpty) {
      setState(() => _emailError = "Email is required");
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      setState(() => _emailError = "Please enter a valid email address");
      isValid = false;
    }

    // Mobile validation
    if (mobileController.text.isEmpty) {
      setState(() => _mobileError = "Mobile number is required");
      isValid = false;
    } else if (mobileController.text.length < 10) {
      setState(() => _mobileError = "Please enter a valid mobile number");
      isValid = false;
    }

    // OTP validation
    if (otpController.text.isEmpty) {
      setState(() => _otpError = "OTP is required");
      isValid = false;
    } else if (otpController.text.length != 4) {
      setState(() => _otpError = "OTP must be 4 digits");
      isValid = false;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(otpController.text)) {
      setState(() => _otpError = "OTP must contain only numbers");
      isValid = false;
    }

    // Password validation
    if (passwordController.text.isEmpty) {
      setState(() => _passwordError = "Password is required");
      isValid = false;
    } else if (!_isLengthValid || !_hasUppercaseAndNumber || !_hasSpecialChar) {
      setState(() => _passwordError = "Password does not meet requirements");
      isValid = false;
    }

    // Confirm password validation
    if (confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = "Please confirm your password");
      isValid = false;
    } else if (passwordController.text != confirmPasswordController.text) {
      setState(() => _confirmPasswordError = "Passwords do not match");
      isValid = false;
    }

    return isValid;
  }

  void _submitForm(BuildContext context) async {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fix all errors before submitting")),
      );
      return;
    }

    final provider = Provider.of<RegisterProvider>(context, listen: false);

    await provider.registerUser(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      mobile: mobileController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      passwordConfirmation: confirmPasswordController.text.trim(),
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegisterProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
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
                  decoration: _inputDecoration("Enter your full name").copyWith(
                    errorText: _nameError,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                ),
                const SizedBox(height: 20),

                // Username
                _buildLabel("Username"),
                TextField(
                  controller: usernameController,
                  decoration: _inputDecoration("Choose a username").copyWith(
                    errorText: _usernameError,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                    LengthLimitingTextInputFormatter(20),
                  ],
                ),
                const SizedBox(height: 20),

                // Email
                _buildLabel("Email"),
                TextField(
                  controller: emailController,
                  decoration: _inputDecoration("Enter your email").copyWith(
                    errorText: _emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(100),
                  ],
                ),
                const SizedBox(height: 20),

                // Mobile Number
                _buildLabel("Mobile Number"),
                IntlPhoneField(
                  controller: mobileController,
                  initialCountryCode: 'IN',
                  decoration: _inputDecoration("Enter your mobile number").copyWith(
                    errorText: _mobileError,
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (phone) {
                    // You can access complete phone number with country code
                    // phone.completeNumber
                  },
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
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
                  onChanged: (value) {
                    setState(() {
                      if (value.length == 4) {
                        _otpError = null;
                      }
                    });
                  },
                ),
                if (_otpError != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    _otpError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),

                // Password
                _buildLabel("Password"),
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  onChanged: (value) {
                    _validatePassword(value);
                    setState(() => _passwordError = null);
                  },
                  decoration: _inputDecoration("Password").copyWith(
                    errorText: _passwordError,
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
                  onChanged: (value) {
                    setState(() => _confirmPasswordError = null);
                  },
                  decoration: _inputDecoration("Confirm Password").copyWith(
                    errorText: _confirmPasswordError,
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
                    onPressed: provider.isLoading ? null : () => _submitForm(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("CONTINUE",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );

  Widget _buildPasswordChecks() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _passwordCheck(_isLengthValid, "Password Must Be At Least 8 Characters"),
          const SizedBox(height: 4),
          _passwordCheck(
              _hasUppercaseAndNumber, "At Least One Uppercase & One Number"),
          const SizedBox(height: 4),
          _passwordCheck(_hasSpecialChar, "At Least One Special Character"),
        ],
      ),
    );
  }

  Widget _passwordCheck(bool valid, String text) {
    return Row(
      children: [
        Icon(valid ? Icons.check_circle : Icons.cancel,
            color: valid ? Colors.green : Colors.red, size: 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: valid ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}


/*
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
*/


