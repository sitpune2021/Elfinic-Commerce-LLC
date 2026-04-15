// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

// class CustomGalleryScreen extends StatefulWidget {
//   final int maxSelection;

//   const CustomGalleryScreen({super.key, this.maxSelection = 5});

//   @override
//   State<CustomGalleryScreen> createState() => _CustomGalleryScreenState();
// }

// class _CustomGalleryScreenState extends State<CustomGalleryScreen> {
//   List<AssetEntity> _assets = [];
//   final List<AssetEntity> _selected = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadImages();
//   }

//   Future<void> _loadImages() async {
//     final permission = await PhotoManager.requestPermissionExtend();
//     if (!permission.isAuth) {
//       PhotoManager.openSetting();
//       return;
//     }

//     final albums = await PhotoManager.getAssetPathList(
//       type: RequestType.image,
//       onlyAll: true,
//     );

//     final media = await albums.first.getAssetListPaged(
//       page: 0,
//       size: 200,
//     );

//     setState(() => _assets = media);
//   }

//   bool _isSelected(AssetEntity asset) => _selected.any((e) => e.id == asset.id);

//   void _toggleSelect(AssetEntity asset) {
//     setState(() {
//       if (_isSelected(asset)) {
//         _selected.removeWhere((e) => e.id == asset.id);
//       } else {
//         if (_selected.length >= widget.maxSelection) return;
//         _selected.add(asset);
//       }
//     });
//   }

//   Future<void> _done() async {
//     final files = <File>[];

//     for (final asset in _selected) {
//       final file = await asset.file;
//       if (file != null) files.add(file);
//     }

//     if (!mounted) return;
//     Navigator.pop(context, files);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:
//             Text('Select Images (${_selected.length}/${widget.maxSelection})'),
//         actions: [
//           TextButton(
//             onPressed: _selected.isEmpty ? null : _done,
//             child: const Text(
//               'Done',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(4),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 4,
//           mainAxisSpacing: 4,
//         ),
//         itemCount: _assets.length,
//         itemBuilder: (context, index) {
//           final asset = _assets[index];
//           final selected = _isSelected(asset);
//           final disable = !selected && _selected.length >= widget.maxSelection;

//           return GestureDetector(
//             onTap: disable ? null : () => _toggleSelect(asset),
//             child: Stack(
//               children: [
//                 AssetEntityImage(
//                   asset,
//                   fit: BoxFit.cover,
//                 ),

//                 /// Selection overlay
//                 Positioned(
//                   top: 6,
//                   right: 6,
//                   child: CircleAvatar(
//                     radius: 12,
//                     backgroundColor: selected ? Colors.blue : Colors.black45,
//                     child: selected
//                         ? Text(
//                             '${_selected.indexOf(asset) + 1}',
//                             style: const TextStyle(
//                                 color: Colors.white, fontSize: 12),
//                           )
//                         : const SizedBox(),
//                   ),
//                 ),

//                 if (disable)
//                   Container(
//                     color: Colors.black.withOpacity(0.4),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
