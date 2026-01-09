import 'package:elfinic_commerce_llc/services/deletet_service.dart';
import 'package:flutter/material.dart';

class DeleteAccountProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> deleteAccount(BuildContext context) async {
    debugPrint("🟡 Provider deleteAccount()");

    _isLoading = true;
    notifyListeners();

    final result = await DeleteAccountService.deleteAccount();

    _isLoading = false;
    notifyListeners();

    if (!context.mounted) {
      debugPrint("⚠️ Context not mounted, stopping SnackBar");
      return false;
    }

    if (result['success'] == true) {
      debugPrint("✅ Delete success");
      return true;
    } else {
      debugPrint("❌ Delete failed: ${result['message']}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      return false;
    }
  }
}
