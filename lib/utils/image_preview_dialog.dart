import 'dart:io';
import 'package:flutter/material.dart';

/// Image preview dialog with zoom and gesture support
class ImagePreviewDialog extends StatefulWidget {
  final File imageFile;
  final List<File> allImages;
  final int initialIndex;

  const ImagePreviewDialog({
    super.key,
    required this.imageFile,
    this.allImages = const [],
    this.initialIndex = 0,
  });

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMultipleImages = widget.allImages.length > 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Background dimmer
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.black87,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Image viewer
          Center(
            child: hasMultipleImages
                ? _buildPageView()
                : _buildSingleImage(widget.imageFile),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Page indicator
          if (hasMultipleImages)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.allImages.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.allImages.length,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
      },
      itemBuilder: (context, index) {
        return _buildSingleImage(widget.allImages[index]);
      },
    );
  }

  Widget _buildSingleImage(File imageFile) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
