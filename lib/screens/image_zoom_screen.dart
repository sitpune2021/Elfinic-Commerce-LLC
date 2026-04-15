import 'package:flutter/material.dart';

class ImageZoomScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String imagePath;

  const ImageZoomScreen({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.imagePath,
  });

  @override
  State<ImageZoomScreen> createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (_, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Image.network(
              widget.imagePath + widget.images[index],
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }
}
