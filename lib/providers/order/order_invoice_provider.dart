import 'dart:io';
import 'dart:typed_data';
import 'package:elfinic_commerce_llc/model/order_history_details_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:elfinic_commerce_llc/services/order_service.dart';
import 'package:elfinic_commerce_llc/widget/pdf_preview_widget.dart';

class OrderInvoiceProvider extends ChangeNotifier {
  bool _downloading = false;
  bool get downloading => _downloading;

  Future<void> downloadInvoice({
    required BuildContext context,
    required int orderId,
  }) async {
    if (_downloading) return;

    _downloading = true;
    notifyListeners();

    // 1️⃣ Download invoice bytes
    Uint8List? bytes =
        await OrderService.downloadInvoiceBytes(orderId: orderId);

    if (!context.mounted) return;

    if (bytes == null) {
      _downloading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice download failed')),
      );
      return;
    }

    // 2️⃣ Open folder picker
    String? folderPath = await FilePicker.platform.getDirectoryPath();

    if (folderPath == null) {
      _downloading = false;
      notifyListeners();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Folder not selected')),
      );
      return;
    }

    // 3️⃣ Save file
    final file = File('$folderPath/invoice_order_$orderId.pdf');
    await file.writeAsBytes(bytes, flush: true);

    if (!context.mounted) return;

    _downloading = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice saved successfully')),
    );

    // 4️⃣ Open preview
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(filePath: file.path),
      ),
    );
  }

  //
  bool isLoading = false;
  OrderHistoryDetailsModel? orderDetails;

  Future<void> loadOrderHistorysDetails({
    required int orderId,
    required int productId,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      orderDetails = await OrderService.fetchOrderHistoryDetails(
        orderId: orderId,
        productId: productId,
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  /// convenience getters
  Datum? get order =>
      orderDetails?.data.isNotEmpty == true ? orderDetails!.data.first : null;

  Address? get address => order?.address;

  List<History> get history => order?.history ?? [];
}
