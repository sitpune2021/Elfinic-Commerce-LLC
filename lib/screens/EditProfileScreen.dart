// ignore_for_file: file_names

import 'dart:io';

import 'package:elfinic_commerce_llc/model/UserProfileModel.dart';
import 'package:elfinic_commerce_llc/providers/profile_provider.dart';
import 'package:elfinic_commerce_llc/widget/custom_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../utils/BaseScreen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // focus nodes
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  // image
  String? _profileImageUrl;
  File? _pickedImage;

  // original values
  String? _originalName;
  String? _originalEmail;
  String? _originalPhone;

  bool get _hasChanges {
    return _nameController.text != (_originalName ?? '') ||
        _emailController.text != (_originalEmail ?? '') ||
        _phoneController.text != (_originalPhone ?? '') ||
        _pickedImage != null;
  }

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchUserProfile();
    });
  }

  void _onFieldChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();

    super.dispose();
  }

  // ===============================
  // SYNC CONTROLLERS (FOCUS SAFE)
  // ===============================
  void _syncControllersWithProfile(Data data) {
    if (!_nameFocus.hasFocus && _nameController.text != data.name) {
      _nameController.text = data.name;
    }

    if (!_emailFocus.hasFocus && _emailController.text != data.email) {
      _emailController.text = data.email;
    }

    if (!_phoneFocus.hasFocus && _phoneController.text != data.mobile) {
      _phoneController.text = data.mobile;
    }

    _profileImageUrl = data.photo;

    _originalName ??= data.name;
    _originalEmail ??= data.email;
    _originalPhone ??= data.mobile;
  }

  void _resetOriginalValuesAfterSuccess() {
    _originalName = _nameController.text.trim();
    _originalEmail = _emailController.text.trim();
    _originalPhone = _phoneController.text.trim();

    _pickedImage = null;

    setState(() {});
  }

  // ===============================
  // IMAGE PICKER
  // ===============================
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;

    final compressed = await _compressImage(File(picked.path));
    setState(() => _pickedImage = compressed);
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
    );

    return compressed != null ? File(compressed.path) : file;
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Scaffold(
        backgroundColor:  Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFFCF8F3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.black.withValues(alpha: 0.06),
            ),
          ),
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Consumer<ProfileProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CustomLoader());
            }

            final data = provider.profile?.data;
            if (data != null) {
              _syncControllersWithProfile(data);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // PROFILE IMAGE
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (_profileImageUrl != null &&
                                    _profileImageUrl!.isNotEmpty)
                                ? NetworkImage(_profileImageUrl!)
                                : null,
                        child: (_pickedImage == null &&
                                (_profileImageUrl == null ||
                                    _profileImageUrl!.isEmpty))
                            ? const Icon(Icons.person,
                                size: 60, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.amber,
                            child: Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildLabel("Profile Name"),
                  _buildTextField(_nameController, focusNode: _nameFocus),

                  const SizedBox(height: 10),
                  _buildLabel("Phone"),
                  _buildPhoneField(),

                  const SizedBox(height: 10),
                  _buildLabel("Email ID"),
                  _buildTextField(_emailController, focusNode: _emailFocus),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          _hasChanges ? Colors.amber : Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: (_hasChanges && !provider.isLoading)
                        ? () async {
                            final profileProvider =
                                context.read<ProfileProvider>();

                            final success = await profileProvider.updateProfile(
                              name: _nameController.text.trim(),
                              mobile: _phoneController.text.trim(),
                              photo: _pickedImage,
                            );

                            if (!mounted) return;

                            if (success) {
                              await profileProvider.fetchUserProfile();

                              _resetOriginalValuesAfterSuccess();
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(
                      provider.isLoading
                          ? "UPDATING..."
                          : (_hasChanges ? "UPDATE PROFILE" : "SAVE DETAILS"),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===============================
  // UI HELPERS
  // ===============================
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

  Widget _buildTextField(
    TextEditingController controller, {
    required FocusNode focusNode,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      controller: _phoneController,
      focusNode: _phoneFocus,
      decoration: InputDecoration(
        filled: true,
        counterText: '',
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      initialCountryCode: 'IN',
    );
  }
}
