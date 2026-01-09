// ignore_for_file: file_names

import 'dart:io';
import 'package:async/async.dart';
import 'package:elfinic_commerce_llc/model/get_review_model.dart';
import 'package:elfinic_commerce_llc/services/review_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ReviewProvider with ChangeNotifier {
  // List<Review> _reviews = [];
  bool _isLoading = false;
  String _error = '';

  // List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String get error => _error;

  int rating = 0;
  bool isUploading = false;
  double uploadProgress = 0;

  CancelableOperation? _uploadTask;

  //add eligibility
  bool _eligible = false;
  bool _loading = false;

  bool get eligible => _eligible;
  bool get loading => _loading;

  List<File> images = [];
  List<File> videos = [];

  File? videoThumbnail;
  bool isVideoThumbLoading = false;
  bool _isVideoProcessing = false;
  bool get isVideoProcessing => _isVideoProcessing;

  bool submitSuccess = false;

  GetReviewModel? _reviewModel;

  GetReviewModel? get reviewModel => _reviewModel;

  /// ---------------- RATING ----------------
  void setRating(int value) {
    rating = value;
    debugPrint('⭐ Provider Rating: $rating');
    notifyListeners();
  }

  /// ---------------- IMAGES ----------------

  void addImages(List<File> files) {
    final remaining = 5 - images.length;
    if (remaining <= 0) {
      debugPrint('❌ Image limit reached (5)');
      return;
    }

    // 🔒 Only take allowed number
    final limitedFiles = files.take(remaining);

    images.addAll(limitedFiles);

    debugPrint('🖼️ Provider Images Count: ${images.length}');
    notifyListeners();
  }

  /// ✅ NEW: Set video processing state
  void setVideoProcessing(bool value) {
    _isVideoProcessing = value;
    notifyListeners();
  }

  /// ---------------- VIDEOS ----------------
  Future<void> addVideo(File file) async {
    videos.clear(); // 🔒 only 1 video allowed
    videoThumbnail = null;
    isVideoThumbLoading = true;
    notifyListeners();

    videos.add(file);

    try {
      final tempDir = await getTemporaryDirectory();
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200,
        quality: 75,
      );

      if (thumbPath != null) {
        videoThumbnail = File(thumbPath);
      }
    } catch (e) {
      debugPrint('❌ Video thumbnail error: $e');
    }

    isVideoThumbLoading = false;
    notifyListeners();
  }

  void removeImage(File file) {
    images.remove(file);
    notifyListeners();
  }

  void removeVideo(File file) {
    videos.clear();
    videoThumbnail = null;
    isVideoThumbLoading = false;
    _isVideoProcessing = false;
    notifyListeners();
  }

  /// ---------------- RESET ----------------
  void resetForm() {
    rating = 0;
    images.clear();
    videos.clear();
    _error = '';
    videoThumbnail = null;
    isVideoThumbLoading = false;
    _isVideoProcessing = false;
    notifyListeners();
    debugPrint('🔄 Provider Form Reset');
  }

  Future<void> loadEligibility(int productId) async {
    debugPrint('🟣 ReviewProvider → loadEligibility START');
    _loading = true;
    notifyListeners();

    _eligible = await ReviewService.checkEligibility(productId: productId);

    debugPrint('🟣 ReviewProvider → eligible = $_eligible');

    _loading = false;
    notifyListeners();
    debugPrint('🟣 ReviewProvider → loadEligibility END');
  }

  void reset() {
    debugPrint('🟣 ReviewProvider → reset');
    _eligible = false;
    _loading = false;
    notifyListeners();
  }

  // add product review
  Future<bool> submitReview({
    required int productId,
    required String title,
    required String content,
  }) async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🟢 PROVIDER SUBMIT START');

    if (rating == 0) {
      _error = 'Please select rating';
      notifyListeners();
      return false;
    }

    isUploading = true;
    submitSuccess = false;
    uploadProgress = 0;
    _error = '';
    notifyListeners();

    _uploadTask = CancelableOperation.fromFuture(
      ReviewService.addReview(
        productId: productId,
        rating: rating,
        title: title,
        content: content,
        images: images,
        videos: videos,
        onProgress: (p) {
          uploadProgress = p;
          debugPrint(
            '📊 PROVIDER PROGRESS: ${(p * 100).toStringAsFixed(1)}%',
          );
          notifyListeners();
        },
      ),
    );

    final success = await _uploadTask!.valueOrCancellation(false);

    isUploading = false;
    uploadProgress = 0;

    if (success) {
      submitSuccess = true;
      debugPrint('✅ UPLOAD SUCCESS');
      resetForm();
    } else {
      submitSuccess = false;
      debugPrint('❌ UPLOAD FAILED / CANCELED');
      _error = 'Upload failed or canceled';
    }

    notifyListeners();
    debugPrint('🟢 PROVIDER SUBMIT END');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━');

    return success;
  }

  void cancelUpload() {
    debugPrint('⛔ CANCEL UPLOAD');
    _uploadTask?.cancel();
    isUploading = false;
    uploadProgress = 0;
    notifyListeners();
  }

  //
  Future<void> loadProductReviews(int productId) async {
    debugPrint('🟣 Provider → loadProductReviews START');

    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await ReviewService.getReviewsByProduct(productId);

    if (result != null) {
      _reviewModel = result;
      debugPrint('✅ Reviews Loaded: ${result.data.reviews.length}');
    } else {
      _error = 'Failed to load reviews';
    }

    _isLoading = false;
    notifyListeners();

    debugPrint('🟣 Provider → loadProductReviews END');
  }

/* ================== REVIEW STATS ================== */

  Map<String, dynamic> getProductReviewStats() {
    if (_reviewModel == null) {
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
      };
    }

    final summary = _reviewModel!.data.ratingSummary;

    return {
      'averageRating': summary.averageRating,
      'totalReviews': summary.totalReviews,
    };
  }
}
