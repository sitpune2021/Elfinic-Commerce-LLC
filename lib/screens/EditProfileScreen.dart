import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../utils/BaseScreen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isPublic = false;
  final TextEditingController _nameController = TextEditingController(text: "Shubham");
  final TextEditingController _lastNameController = TextEditingController(text: "Gone");
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF8F3),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFFCF8F3),
          surfaceTintColor:Color(0xFFFCF8F3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile avatar with camera icon
              Stack(
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.amber,
                      child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
      
              // Profile Name
              _buildLabel("Profile Name"),
              _buildTextField(_nameController, suffixIcon: Icons.verified_outlined),
      
              const SizedBox(height: 10),
              _buildLabel("About Me"),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Lorem ipsum dolor sit amet consectetur. Ornare at commodo pharetra integer "
                      "hendrerit nibh duis et mi. Nisl sed congue ullamcorper nibh nibh ultrices. "
                      "Elementum convallis nullam euismod gravida.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
      
              const SizedBox(height: 20),
              _buildLabel("Overview"),
              const Text(
                "Lorem ipsum dolor sit amet consectetur. Ornare at commodo pharetra integer "
                    "hendrerit nibh duis et mi. Nisl sed congue ullamcorper nibh nibh ultrices. "
                    "Elementum convallis nullam euismod gravida.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
      
              const SizedBox(height: 20),
              _buildLabel("First Name"),
              _buildTextField(_nameController, suffixIcon: Icons.verified_outlined),
      
              const SizedBox(height: 10),
              _buildLabel("Last Name"),
              _buildTextField(_lastNameController, suffixIcon: Icons.verified_outlined),
      
              const SizedBox(height: 10),
              _buildLabel("Phone"),
              _buildPhoneField(),
      
      
              const SizedBox(height: 10),
              _buildLabel("Email ID"),
              _buildTextField(_emailController),
      
              const SizedBox(height: 10),
              _buildLabel("Birthdate"),
              _buildTextField(_birthdateController, suffixIcon: Icons.calendar_today_outlined),
      
              const SizedBox(height: 10),
              _buildLabel("Address"),
              _buildTextField(_addressController, suffixIcon: Icons.location_on_outlined),
      
              const SizedBox(height: 20),
              // Privacy Settings
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Privacy Settings",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Decide if other members of Elfinic.com can view your profile",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Public Profile",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Members can see and interact with you.",
                                style: TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                        Switch(
                          value: isPublic,
                          onChanged: (val) {
                            setState(() => isPublic = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      
              const SizedBox(height: 20),
      
              // Save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.grey.shade600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () {},
                child: const Text(
                  "SAVE DETAILS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, {IconData? suffixIcon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.green, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: "Enter your mobile number",
        filled: true,
        fillColor: Colors.white, // background color
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // rounded corners
          borderSide: BorderSide.none,
        ),
      ),
      initialCountryCode: 'IN', // default country
      dropdownIcon: const Icon(
        Icons.arrow_drop_down,
        color: Colors.black54,
      ),
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
      ),
      flagsButtonPadding: const EdgeInsets.only(left: 12),
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      onChanged: (phone) {
        print(phone.completeNumber); // full number with country code
      },
    );
  }

  // Widget _buildPhoneField() {
  //   return TextField(
  //     controller: _phoneController,
  //     keyboardType: TextInputType.phone,
  //     decoration: InputDecoration(
  //       prefixIcon: Padding(
  //         padding: const EdgeInsets.all(12.0),
  //         child: Text("+91", style: TextStyle(fontSize: 14, color: Colors.black87)),
  //       ),
  //       suffixIcon: const Icon(Icons.verified_outlined, color: Colors.green, size: 20),
  //       filled: true,
  //       fillColor: Colors.white,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(30),
  //         borderSide: BorderSide.none,
  //       ),
  //       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
  //     ),
  //   );
  // }
}
