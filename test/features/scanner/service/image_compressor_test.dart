import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/features/scanner/service/image_compressor.dart';

import 'package:flutter_image_compress_platform_interface/flutter_image_compress_platform_interface.dart';

class MockFlutterImageCompressPlatform extends FlutterImageCompressPlatform {
  final List<MethodCall> log = [];

  @override
  Future<Uint8List?> compressWithFile(
    String path, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
    int inSampleSize = 1,
  }) async {
    log.add(MethodCall('compressWithFile', {'path': path}));
    return Uint8List(0);
  }

  @override
  Future<XFile?> compressAndGetFile(
    String path,
    String targetPath, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
    int inSampleSize = 1,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> compressAssetImage(
    String assetName, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> compressWithList(
    Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
    int numberOfRetries = 5,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> showNativeLog(bool value) async {}

  @override
  Future<void> ignoreCheckSupportPlatform(bool value) async {}

  @override
  FlutterImageCompressValidator get validator => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlutterImageCompressPlatform mockPlatform;
  late File tempFile;

  setUp(() async {
    mockPlatform = MockFlutterImageCompressPlatform();
    FlutterImageCompressPlatform.instance = mockPlatform;

    tempFile = File('${Directory.systemTemp.path}/test_image.jpg');
    await tempFile.writeAsBytes([0, 1, 2, 3]); // Dummy content
  });

  tearDown(() async {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  test('compressWithFile calls correct method channel', () async {
    final compressor = ImageCompressor();
    // Use the absolute path of the temp file
    await compressor.compressWithFile(tempFile.path);

    expect(mockPlatform.log, hasLength(1));
    expect(mockPlatform.log.first.method, 'compressWithFile');
    final args = mockPlatform.log.first.arguments as Map;
    expect(args['path'], tempFile.path);
  });
}
