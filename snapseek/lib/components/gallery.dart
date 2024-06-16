import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPermission {
  Future<bool> requestPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      status = await Permission.photos.request();
    }
    print("Permission stats: ${status.isGranted}");
    return status.isGranted;
  }

  Future<List<AssetEntity>> loadImages() async {
    final bool isAuthorized = await requestPermission();
    if (!isAuthorized) {
      throw Exception('Permission not granted');
    }
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
    if (albums.isEmpty) {
      return [];
    }
    final List<AssetEntity> photos = await albums.first.getAssetListRange(start: 0, end: 10000);
    if (photos.isEmpty) {
      return [];
    }
    return photos;
  }
}


class Gallery extends StatefulWidget {
  const Gallery({super.key});
  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late Future<List<AssetEntity>> _images;

  @override
  void initState() {
    super.initState();
    _images = GalleryPermission().loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssetEntity>>(
      future: _images,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator()
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}")
          );
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          return const Center(child: Text("No images found"));
        } else if (snapshot.hasData) {
          final images = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return FutureBuilder<Uint8List?>(
                future: images[index].thumbnailData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                  }
                  return const Center(child: CircularProgressIndicator());
                }
              );
            }
          );
        } else {
          return const Center(child: Text("No images found"));
        }
      }
    );
  }
}
