import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'DashboardScreen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

/*class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;



  // Add this flag
  static const bool SHOW_OPTIONAL_UPDATE_DIALOG = false;


  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      checkVersionAndNavigate();
    });
  }

  // Future<void> checkVersionAndNavigate() async {
  //   try {
  //     final packageInfo = await PackageInfo.fromPlatform();
  //     String currentVersion = packageInfo.version;
  //
  //     // String currentVersion = "1.0.0"; // For testing old version
  //     final versionData = await VersionService.checkVersion(currentVersion);
  //
  //     // 🔴 FORCE UPDATE
  //     if (versionData.forceUpdate) {
  //       if (!mounted) return;
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => ForceUpdateScreen(storeUrl: versionData.storeUrl),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     // 🔑 Token check
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("auth_token");
  //
  //     if (!mounted) return;
  //
  //     // 🟡 Optional update - show dialog if available
  //     if (versionData.updateRequired) {
  //       showOptionalUpdateDialog(context, versionData);
  //     } else {
  //       navigateBasedOnToken(token);
  //     }
  //   } catch (e) {
  //     print("Splash error: $e");
  //     // On error, proceed to login/dashboard
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString("auth_token");
  //     if (!mounted) return;
  //     navigateBasedOnToken(token);
  //   }
  // }
  Future<void> checkVersionAndNavigate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      final versionData = await VersionService.checkVersion(currentVersion);

      // 🔴 FORCE UPDATE
      if (versionData.forceUpdate) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ForceUpdateScreen(storeUrl: versionData.storeUrl),
          ),
        );
        return;
      }

      // 🔑 Token check
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");

      if (!mounted) return;

      // 🟡 Optional update - controlled by flag
      if (versionData.updateRequired && SHOW_OPTIONAL_UPDATE_DIALOG) {
        showOptionalUpdateDialog(context, versionData);
      } else {
        navigateBasedOnToken(token);
      }
    } catch (e) {
      print("Splash error: $e");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      if (!mounted) return;
      navigateBasedOnToken(token);
    }
  }
  void navigateBasedOnToken(String? token) {
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void showOptionalUpdateDialog(BuildContext context, VersionModel versionData) {
    const Color primaryColor = Color(0xFFD39841);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.shopping_cart_checkout, color: primaryColor),
            SizedBox(width: 8),
            Text("New Update Available"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.system_update_alt,
              size: 60,
              color: primaryColor,
            ),
            const SizedBox(height: 12),
            Text(
              "Great news! A new version ${versionData.latestVersion} of our shopping app is available.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 10),
            const Text(
              "Update now for better performance, new features and smoother shopping experience.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.timer_outlined, color: Colors.grey),
            label: const Text(
              "Later",
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () {
              Navigator.pop(context);
              navigateBasedOnToken(null);
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text("Update Now"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final uri = Uri.parse(versionData.storeUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash_screen.gif"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class VersionModel {
  final bool forceUpdate;
  final bool updateRequired;
  final String latestVersion;
  final String minSupportedVersion;
  final String storeUrl;

  VersionModel({
    required this.forceUpdate,
    required this.updateRequired,
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.storeUrl,
  });

  factory VersionModel.fromJson(Map<String, dynamic> json) {
    return VersionModel(
      forceUpdate: json['force_update'] ?? false,
      updateRequired: json['update_required'] ?? false,
      latestVersion: json['latest_version'] ?? '',
      minSupportedVersion: json['min_supported_version'] ?? '',
      storeUrl: json['store_url'] ?? '',
    );
  }
}

class VersionService {
  static const String baseUrl = "https://admin.elfinic.com/api";

  static Future<VersionModel> checkVersion(String currentVersion) async {
    final url = Uri.parse("$baseUrl/check-version");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "platform": "android",
          "version": currentVersion,
        }),
      );

      logApi(
        title: "Check Version",
        url: url.toString(),
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == "success") {
          return VersionModel.fromJson(jsonResponse);
        } else {
          throw Exception("API returned error: ${jsonResponse['message']}");
        }
      } else {
        throw Exception("HTTP Error ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("Version check error: $e");
      rethrow;
    }
  }

  static Future<bool> createVersion({
    required String platform,
    required String latestVersion,
    required String minSupportedVersion,
    required String storeUrl,
  }) async {
    final url = Uri.parse("$baseUrl/StoreVersions");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "platform": platform,
          "latest_version": latestVersion,
          "min_supported_version": minSupportedVersion,
          "store_url": storeUrl,
        }),
      );

      logApi(
        title: "Create Version",
        url: url.toString(),
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['status'] == "success";
      }
      return false;
    } catch (e) {
      print("Create version error: $e");
      return false;
    }
  }

  static Future<bool> updateVersion({
    required int id,
    required String platform,
    required String latestVersion,
    required String minSupportedVersion,
    required String storeUrl,
  }) async {
    final url = Uri.parse("$baseUrl/UpdateVersions");

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "id": id,
          "platform": platform,
          "latest_version": latestVersion,
          "min_supported_version": minSupportedVersion,
          "store_url": storeUrl,
        }),
      );

      logApi(
        title: "Update Version",
        url: url.toString(),
        statusCode: response.statusCode,
        responseBody: response.body,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['status'] == "success";
      }
      return false;
    } catch (e) {
      print("Update version error: $e");
      return false;
    }
  }
}

void logApi({
  required String title,
  required String url,
  required int statusCode,
  required String responseBody,
}) {
  debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
  debugPrint("API: $title");
  debugPrint("URL: $url");
  debugPrint("Status Code: $statusCode");
  debugPrint("Response Body: $responseBody");
  debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
}

class ForceUpdateScreen extends StatelessWidget {
  final String storeUrl;

  const ForceUpdateScreen({super.key, required this.storeUrl});

  Future<void> openStore() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $storeUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.system_update, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Update Required",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "A new version of the app is available. "
                    "Please update to continue using the app.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: openStore,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Update Now",
                    style: TextStyle(fontSize: 16),
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

class CreateVersionScreen extends StatefulWidget {
  const CreateVersionScreen({super.key});

  @override
  State<CreateVersionScreen> createState() => _CreateVersionScreenState();
}

class _CreateVersionScreenState extends State<CreateVersionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController latestController = TextEditingController();
  final TextEditingController minController = TextEditingController();
  final TextEditingController storeUrlController = TextEditingController();

  bool isLoading = false;
  String selectedPlatform = "android";

  Future<void> handleCreateVersion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await VersionService.createVersion(
      platform: selectedPlatform,
      latestVersion: latestController.text.trim(),
      minSupportedVersion: minController.text.trim(),
      storeUrl: storeUrlController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Version created successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create version")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Version")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedPlatform,
                items: const [
                  DropdownMenuItem(value: "android", child: Text("Android")),
                  DropdownMenuItem(value: "ios", child: Text("iOS")),
                ],
                onChanged: (val) {
                  setState(() => selectedPlatform = val!);
                },
                decoration: const InputDecoration(
                  labelText: "Platform",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: latestController,
                decoration: const InputDecoration(
                  labelText: "Latest Version",
                  hintText: "1.2.0",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter latest version" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: minController,
                decoration: const InputDecoration(
                  labelText: "Minimum Supported Version",
                  hintText: "1.0.0",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v!.isEmpty ? "Enter minimum supported version" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: storeUrlController,
                decoration: const InputDecoration(
                  labelText: "Store URL",
                  hintText: "https://play.google.com/store/apps/details?id=com.demo",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter store URL" : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleCreateVersion,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Create Version"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateVersionScreen extends StatefulWidget {
  final int id;
  final String platform;
  final String latestVersion;
  final String minSupportedVersion;
  final String storeUrl;

  const UpdateVersionScreen({
    super.key,
    required this.id,
    required this.platform,
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.storeUrl,
  });

  @override
  State<UpdateVersionScreen> createState() => _UpdateVersionScreenState();
}

class _UpdateVersionScreenState extends State<UpdateVersionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController latestController;
  late TextEditingController minController;
  late TextEditingController storeUrlController;

  bool isLoading = false;
  String selectedPlatform = "android";

  @override
  void initState() {
    super.initState();
    selectedPlatform = widget.platform;
    latestController = TextEditingController(text: widget.latestVersion);
    minController = TextEditingController(text: widget.minSupportedVersion);
    storeUrlController = TextEditingController(text: widget.storeUrl);
  }

  Future<void> updateVersion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final success = await VersionService.updateVersion(
      id: widget.id,
      platform: selectedPlatform,
      latestVersion: latestController.text.trim(),
      minSupportedVersion: minController.text.trim(),
      storeUrl: storeUrlController.text.trim(),
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Version updated successfully")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update version")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Version")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedPlatform,
                items: const [
                  DropdownMenuItem(value: "android", child: Text("Android")),
                  DropdownMenuItem(value: "ios", child: Text("iOS")),
                ],
                onChanged: (val) {
                  setState(() => selectedPlatform = val!);
                },
                decoration: const InputDecoration(
                  labelText: "Platform",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: latestController,
                decoration: const InputDecoration(
                  labelText: "Latest Version",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter latest version" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: minController,
                decoration: const InputDecoration(
                  labelText: "Minimum Supported Version",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v!.isEmpty ? "Enter minimum supported version" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: storeUrlController,
                decoration: const InputDecoration(
                  labelText: "Store URL",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Enter store URL" : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateVersion,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Update Version"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}*/

//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );
//
//     _controller.forward();
//
//     Future.delayed(const Duration(seconds: 3), () {
//       checkVersionAndNavigate();
//     });
//
//   }
//
//   Future<void> checkVersionAndNavigate() async {
//     try {
//       final packageInfo = await PackageInfo.fromPlatform();
//       String currentVersion = packageInfo.version;
//
//       // String currentVersion = "1.0.0"; // try old version
//       final versionData = await VersionService.checkVersion(currentVersion);
//
//       // 🔴 FORCE UPDATE
//       if (versionData.forceUpdate) {
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ForceUpdateScreen(storeUrl: versionData.storeUrl),
//           ),
//         );
//         return;
//       }
//
//       // 🟡 Optional update (you can show dialog later if needed)
//       if (versionData.updateRequired) {
//         print("Optional update available: ${versionData.latestVersion}");
//         // You can show a popup if you want
//       }
//
//       // 🔑 Token check
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString("auth_token");
//
//       if (!mounted) return;
//
//       if (token != null && token.isNotEmpty) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const DashboardScreen()),
//         );
//       } else {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       }
//     } catch (e) {
//       print("Splash error: $e");
//     }
//   }
//
//
//   bool isForceUpdate(String current, String min) {
//     List<int> c = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
//     List<int> m = min.split('.').map((e) => int.tryParse(e) ?? 0).toList();
//
//     for (int i = 0; i < 3; i++) {
//       if (c[i] < m[i]) return true;
//       if (c[i] > m[i]) return false;
//     }
//     return false;
//   }
//
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/splash_screen.gif"),
//             fit: BoxFit.cover,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// class VersionModel {
//   final bool forceUpdate;
//   final bool updateRequired;
//   final String latestVersion;
//   final String minSupportedVersion;
//   final String storeUrl;
//
//   VersionModel({
//     required this.forceUpdate,
//     required this.updateRequired,
//     required this.latestVersion,
//     required this.minSupportedVersion,
//     required this.storeUrl,
//   });
//
//   factory VersionModel.fromJson(Map<String, dynamic> json) {
//     return VersionModel(
//       forceUpdate: json['force_update'],
//       updateRequired: json['update_required'],
//       latestVersion: json['latest_version'],
//       minSupportedVersion: json['min_supported_version'],
//       storeUrl: json['store_url'],
//     );
//   }
// }
//
//
// void logApi({
//   required String title,
//   required String url,
//   required int statusCode,
//   required String responseBody,
// }) {
//   print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
//   print("API: $title");
//   print("URL: $url");
//   print("Status Code: $statusCode");
//   print("Response Body: $responseBody");
//   print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
// }
//
//
// class VersionService {
//
//   static Future<bool> createVersion({
//     required String platform,
//     required String latestVersion,
//     required String minSupportedVersion,
//     required String storeUrl,
//   }) async {
//     final url = Uri.parse("https://admin.elfinic.com/api/StoreVersions");
//
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//       },
//       body: jsonEncode({
//         "platform": platform,
//         "latest_version": latestVersion,
//         "min_supported_version": minSupportedVersion,
//         "store_url": storeUrl,
//       }),
//     );
//
//     print("Create Status: ${response.statusCode}");
//     print("Create Body: ${response.body}");
//
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final json = jsonDecode(response.body);
//       return json['status'] == "success";
//     } else {
//       return false;
//     }
//   }
//
//
//
//   static Future<VersionModel> checkVersion(String currentVersion) async {
//     final url = Uri.parse("https://admin.elfinic.com/api/check-version");
//
//     final response = await http.post(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//       },
//       body: jsonEncode({
//         "platform": "android",
//         "version": currentVersion,
//       }),
//     );
//
//     logApi(
//       title: "Check Version",
//       url: url.toString(),
//       statusCode: response.statusCode,
//       responseBody: response.body,
//     );
//
//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       return VersionModel.fromJson(json);
//     } else {
//       throw Exception("Failed to check version");
//     }
//   }
//
//
//
//   static Future<bool> updateVersion({
//     required int id,
//     required String platform,
//     required String latestVersion,
//     required String minSupportedVersion,
//     required String storeUrl,
//   }) async {
//     final url = Uri.parse("https://admin.elfinic.com/api/UpdateVersions");
//
//     final response = await http.put(
//       url,
//       headers: {
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//       },
//       body: jsonEncode({
//         "id": id,
//         "platform": platform,
//         "latest_version": latestVersion,
//         "min_supported_version": minSupportedVersion,
//         "store_url": storeUrl,
//       }),
//     );
//
//     logApi(
//       title: "Update Version",
//       url: url.toString(),
//       statusCode: response.statusCode,
//       responseBody: response.body,
//     );
//
//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       return json['status'] == "success";
//     } else {
//       return false;
//     }
//   }
//
//
// }
//
//
//
// class UpdateVersionScreen extends StatefulWidget {
//   final int id;
//   final String platform;
//   final String latestVersion;
//   final String minSupportedVersion;
//   final String storeUrl;
//
//   const UpdateVersionScreen({
//     super.key,
//     required this.id,
//     required this.platform,
//     required this.latestVersion,
//     required this.minSupportedVersion,
//     required this.storeUrl,
//   });
//
//   @override
//   State<UpdateVersionScreen> createState() => _UpdateVersionScreenState();
// }
//
// class _UpdateVersionScreenState extends State<UpdateVersionScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   late TextEditingController latestController;
//   late TextEditingController minController;
//   late TextEditingController storeUrlController;
//
//   bool isLoading = false;
//   String selectedPlatform = "android";
//
//   @override
//   void initState() {
//     super.initState();
//     selectedPlatform = widget.platform;
//     latestController = TextEditingController(text: widget.latestVersion);
//     minController = TextEditingController(text: widget.minSupportedVersion);
//     storeUrlController = TextEditingController(text: widget.storeUrl);
//   }
//
//   Future<void> updateVersion() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => isLoading = true);
//
//     final success = await VersionService.updateVersion(
//       id: widget.id,
//       platform: selectedPlatform,
//       latestVersion: latestController.text,
//       minSupportedVersion: minController.text,
//       storeUrl: storeUrlController.text,
//     );
//
//     setState(() => isLoading = false);
//
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Version updated successfully")),
//       );
//       Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to update version")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Update Version")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               DropdownButtonFormField<String>(
//                 value: selectedPlatform,
//                 items: const [
//                   DropdownMenuItem(value: "android", child: Text("Android")),
//                   DropdownMenuItem(value: "ios", child: Text("iOS")),
//                 ],
//                 onChanged: (val) {
//                   setState(() => selectedPlatform = val!);
//                 },
//                 decoration: const InputDecoration(
//                   labelText: "Platform",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               TextFormField(
//                 controller: latestController,
//                 decoration: const InputDecoration(
//                   labelText: "Latest Version",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) => v!.isEmpty ? "Enter latest version" : null,
//               ),
//               const SizedBox(height: 12),
//
//               TextFormField(
//                 controller: minController,
//                 decoration: const InputDecoration(
//                   labelText: "Min Supported Version",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) => v!.isEmpty ? "Enter min supported version" : null,
//               ),
//               const SizedBox(height: 12),
//
//               TextFormField(
//                 controller: storeUrlController,
//                 decoration: const InputDecoration(
//                   labelText: "Store URL",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) => v!.isEmpty ? "Enter store URL" : null,
//               ),
//               const SizedBox(height: 20),
//
//            /*   ElevatedButton(
//                 onPressed: () async {
//                   final versionData = await VersionService.checkVersion("1.0.0");
//                   print(versionData.forceUpdate);
//                   print(versionData.updateRequired);
//                 },
//                 child: Text("Check Version Manually"),
//               ),*/
//
//                   SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : updateVersion,
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Update"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
// class ForceUpdateScreen extends StatelessWidget {
//   final String storeUrl;
//
//   const ForceUpdateScreen({super.key, required this.storeUrl});
//
//   Future<void> openStore() async {
//     final uri = Uri.parse(storeUrl);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.system_update, size: 80, color: Colors.blue),
//               SizedBox(height: 20),
//               Text(
//                 "Update Required",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 12),
//               Text(
//                 "Please update the app to continue.",
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: openStore,
//                   child: Text("Update Now"),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// class CreateVersionScreen extends StatefulWidget {
//   const CreateVersionScreen({super.key});
//
//   @override
//   State<CreateVersionScreen> createState() => _CreateVersionScreenState();
// }
//
// class _CreateVersionScreenState extends State<CreateVersionScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController latestController = TextEditingController();
//   final TextEditingController minController = TextEditingController();
//   final TextEditingController storeUrlController = TextEditingController();
//
//   bool isLoading = false;
//   String selectedPlatform = "android";
//
//   Future<void> handleCreateVersion() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => isLoading = true);
//
//     final success = await VersionService.createVersion(
//       platform: selectedPlatform,
//       latestVersion: latestController.text.trim(),
//       minSupportedVersion: minController.text.trim(),
//       storeUrl: storeUrlController.text.trim(),
//     );
//
//     setState(() => isLoading = false);
//
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Version created successfully")),
//       );
//       Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Failed to create version")),
//       );
//     }
//   }
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Create Version")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               DropdownButtonFormField<String>(
//                 value: selectedPlatform,
//                 items: const [
//                   DropdownMenuItem(value: "android", child: Text("Android")),
//                   DropdownMenuItem(value: "ios", child: Text("iOS")),
//                 ],
//                 onChanged: (val) {
//                   setState(() => selectedPlatform = val!);
//                 },
//                 decoration: const InputDecoration(
//                   labelText: "Platform",
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 12),
//
//               TextFormField(
//                 controller: latestController,
//                 decoration: const InputDecoration(
//                   labelText: "Latest Version",
//                   hintText: "1.2.0",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) => v!.isEmpty ? "Enter latest version" : null,
//               ),
//               const SizedBox(height: 12),
//
//               TextFormField(
//                 controller: minController,
//                 decoration: const InputDecoration(
//                   labelText: "Min Supported Version",
//                   hintText: "1.0.0",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) =>
//                 v!.isEmpty ? "Enter min supported version" : null,
//               ),
//               const SizedBox(height: 12),
//
//               TextFormField(
//                 controller: storeUrlController,
//                 decoration: const InputDecoration(
//                   labelText: "Store URL",
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (v) => v!.isEmpty ? "Enter store URL" : null,
//               ),
//               const SizedBox(height: 20),
//
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : handleCreateVersion,
//                   child: isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text("Create Version"),
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
const String androidStoreUrl =
    "https://play.google.com/store/apps/details?id=com.sit.elfinic_commerce_llc";

const String iosStoreUrl =
    "https://apps.apple.com/app/idXXXXXXXXXX"; // 🔁 replace with real App Store ID

const bool tempForceUpdateCheck = false; // 🔁 set false later
String getStoreUrl() {
  final platform = PlatformHelper.platform;

  if (platform == "android") {
    return androidStoreUrl;
  } else if (platform == "ios") {
    return iosStoreUrl;
  }
  return androidStoreUrl; // fallback
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;




  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _initFlow();
  }

  /// 🔢 VERSION COMPARE
  int compareVersion(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final a = i < v1Parts.length ? v1Parts[i] : 0;
      final b = i < v2Parts.length ? v2Parts[i] : 0;
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }

  Future<void> _initFlow() async {
    await Future.delayed(const Duration(seconds: 2));

    /// 🚨 TEMP FORCE UPDATE CHECK
    if (tempForceUpdateCheck) {
      _showForceUpdate();
      return;
    }

    /// 🔹 VERSION CHECK (ORIGINAL LOGIC)
    final platform = PlatformHelper.platform;
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    final storeVersion = await VersionApiService.getVersion(platform);

    if (storeVersion != null) {
      if (compareVersion(appVersion, storeVersion.minSupportedVersion) < 0) {
        _showForceUpdate();
        return;
      }

      if (compareVersion(appVersion, storeVersion.latestVersion) < 0) {
        await _showOptionalUpdate();
      }
    }

    /// 🔹 AUTH CHECK
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    if (!mounted) return;

  /*  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
        token != null && token.isNotEmpty
            ? const DashboardScreen()
            : const LoginScreen(),
      ),
    );*/

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardScreen(),
      ),
    );
  }


  /// ❌ FORCE UPDATE (BLOCK USER)
  void _showForceUpdate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Update Required"),
        content: const Text(
          "Please update the app to continue using it.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              launchUrl(
                Uri.parse(getStoreUrl()),
                mode: LaunchMode.externalApplication,
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }



  /// ⚠️ OPTIONAL UPDATE
  Future<void> _showOptionalUpdate() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Available"),
        content: const Text("A newer version is available."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          TextButton(
            onPressed: () {
              launchUrl(
                Uri.parse(getStoreUrl()),
                mode: LaunchMode.externalApplication,
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image.asset(
          "assets/images/splash_screen.gif",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}



class PlatformHelper {
  static String get platform {
    if (kIsWeb) return "web";
    if (Platform.isAndroid) return "android";
    if (Platform.isIOS) return "ios";
    return "unknown";
  }
}
class StoreVersion {
  final int id;
  final String latestVersion;
  final String minSupportedVersion;
  final String storeUrl;

  StoreVersion({
    required this.id,
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.storeUrl,
  });

  factory StoreVersion.fromJson(Map<String, dynamic> json) {
    return StoreVersion(
      id: json['id'],
      latestVersion: json['latest_version'],
      minSupportedVersion: json['min_supported_version'],
      storeUrl: json['store_url'],
    );
  }
}



// class VersionApiService {
//   static const String baseUrl = "https://admin.elfinic.com/api";
//
//   static Future<StoreVersion?> getVersion(String platform) async {
//     final response = await http.post(
//       Uri.parse("$baseUrl/getVersions"),
//       headers: {"Content-Type": "application/json"},
//       body: json.encode({"platform": platform}),
//     );
//
//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//
//       if (jsonData['status'] == 'success' &&
//           jsonData['data'] != null &&
//           jsonData['data'].isNotEmpty) {
//         return StoreVersion.fromJson(jsonData['data'][0]);
//       }
//     }
//     return null;
//   }
// }
class VersionApiService {
  static const String baseUrl = "https://admin.elfinic.com/api";

  static Future<StoreVersion?> getVersion(String platform) async {
    try {
      final response = await http
          .post(
        Uri.parse("$baseUrl/getVersions"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"platform": platform}),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success' &&
            jsonData['data'] != null &&
            jsonData['data'].isNotEmpty) {
          return StoreVersion.fromJson(jsonData['data'][0]);
        }
      }
    } catch (e) {
      debugPrint("Version API error: $e");
    }
    return null; // allow app to continue
  }
}


/*class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );



    _controller.forward();

    /// 🔑 Check if token exists after delay
    Timer(const Duration(seconds: 6), () async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("auth_token");
      if (token != null && token.isNotEmpty) {
        if (!mounted) return;

        // ✅ Already logged in → Go to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        if (!mounted) return;

        // ❌ Not logged in → Go to Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/splash_screen.gif"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}*/


