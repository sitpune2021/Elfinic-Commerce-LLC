// import 'dart:io';
// import 'package:elfinic_commerce_llc/services/api_service.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/foundation.dart';

// class OrderService {
//   static Future<File?> downloadInvoice({
//     required int orderId,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;
//       final token = prefs.getString('auth_token') ?? '';

//       debugPrint('👤 USER ID: $userId');
//       debugPrint('🔑 TOKEN EXISTS: ${token.isNotEmpty}');

//       if (userId == 0 || token.isEmpty) {
//         debugPrint('❌ AUTH ERROR');
//         return null;
//       }

//       // ✅ Android permission (13+ safe)
//       if (Platform.isAndroid) {
//         if (await Permission.manageExternalStorage.isDenied) {
//           final status = await Permission.manageExternalStorage.request();
//           if (!status.isGranted) return null;
//         }
//       }
//       final uri = Uri.parse(ApiService.orderInvoicedownload).replace(
//         queryParameters: {
//           'user_id': userId.toString(),
//           'order_id': "8",
//           // 'order_id': orderId.toString(), // ✅ FIXED
//         },
//       );

//       debugPrint('🌐 INVOICE API: $uri');

//       final response = await http.get(
//         uri,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/pdf',
//         },
//       );

//       if (response.statusCode != 200) {
//         debugPrint('❌ API ERROR: ${response.statusCode}');
//         return null;
//       }

//       Uint8List bytes = response.bodyBytes;

//       // 📂 Downloads directory
//       final Directory dir = Platform.isAndroid
//           ? Directory('/storage/emulated/0/Download')
//           : await getApplicationDocumentsDirectory();

//       if (!await dir.exists()) {
//         await dir.create(recursive: true);
//       }

//       final file = File('${dir.path}/invoice_order_$orderId.pdf');
//       await file.writeAsBytes(bytes, flush: true);

//       debugPrint('✅ INVOICE SAVED: $file');
//       return file;
//     } catch (e) {
//       debugPrint('❌ DOWNLOAD ERROR: $e');
//       return null;
//     }
//   }
// }

import 'package:elfinic_commerce_llc/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  static Future<Uint8List?> downloadInvoiceBytes({
    required int orderId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('user_id') ?? '0') ?? 0;
      final token = prefs.getString('auth_token') ?? '';

      if (userId == 0 || token.isEmpty) return null;

      final uri = Uri.parse(ApiService.orderInvoicedownload).replace(
        queryParameters: {'user_id': userId.toString(), 'order_id': "8"},
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode != 200) return null;

      return response.bodyBytes;
    } catch (e) {
      debugPrint('❌ Download error: $e');
      return null;
    }
  }
}
