import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

abstract class ImageCompressor {
  Future<Uint8List?> compressWithFile(
    String path, {
    int minWidth = 1024,
    int minHeight = 1024,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  });
}

class DefaultImageCompressor implements ImageCompressor {
  @override
  Future<Uint8List?> compressWithFile(
    String path, {
    int minWidth = 1024,
    int minHeight = 1024,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) {
    return FlutterImageCompress.compressWithFile(
      path,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      rotate: rotate,
      autoCorrectionAngle: autoCorrectionAngle,
      format: format,
      keepExif: keepExif,
      numberOfRetries: numberOfRetries,
    );
  }
}
