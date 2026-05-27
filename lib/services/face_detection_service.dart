import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bellspalsy_app/app/modules/detection/models/detection_face_status.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;

class FaceDetectionService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: true,
    ),
  );

  bool _busy = false;

  

  Future<DetectionFaceStatus?> processImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_busy) return null;
    _busy = true;

    try {
      final inputImage = _toInputImage(image, camera);

      if (inputImage == null) {
        debugPrint('InputImage conversion failed');
        return DetectionFaceStatus.noFace;
      }

      final faces = await _detector.processImage(inputImage);

      if (faces.isEmpty) return DetectionFaceStatus.noFace;
      if (faces.length > 1) return DetectionFaceStatus.multipleFaces;

      return DetectionFaceStatus.valid;
    } catch (e) {
      debugPrint('MLKit error: $e');
      return DetectionFaceStatus.noFace;
    } finally {
      _busy = false;
    }
  }

  Future<Map<String, dynamic>> analyzeBellPalsy(
    Map<String, List<String>> frames, {
    String mode = 'quick',
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/detection/analyze"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "frames": frames,
          "mode": mode,
          "user_id": 1,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body["success"] == true) {
        return Map<String, dynamic>.from(body["data"]);
      }

      throw Exception(body["message"] ?? "Gagal menganalisis wajah");
    } catch (e) {
      debugPrint("analyzeBellPalsy error: $e");
      rethrow;
    }
  }

  InputImage? _toInputImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);

    if (rotation == null) {
      debugPrint('Invalid rotation: ${camera.sensorOrientation}');
      return null;
    }

    final size = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    if (Platform.isAndroid) {
      if (image.planes.length < 3) {
        debugPrint('Android image does not have 3 planes');
        return null;
      }

      if (image.format.group != ImageFormatGroup.yuv420) {
        debugPrint('Unsupported Android image format: ${image.format.group}');
        return null;
      }

      final nv21Bytes = _convertYUV420ToNV21(image);
      if (nv21Bytes == null) {
        debugPrint('Failed converting YUV420 to NV21');
        return null;
      }

      return InputImage.fromBytes(
        bytes: nv21Bytes,
        metadata: InputImageMetadata(
          size: size,
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    }

    if (Platform.isIOS) {
      if (image.planes.isEmpty) {
        debugPrint('iOS image has no planes');
        return null;
      }

      if (image.format.group != ImageFormatGroup.bgra8888) {
        debugPrint('Unsupported iOS image format: ${image.format.group}');
        return null;
      }

      return InputImage.fromBytes(
        bytes: image.planes.first.bytes,
        metadata: InputImageMetadata(
          size: size,
          rotation: rotation,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );
    }

    debugPrint('Unsupported platform');
    return null;
  }

  Uint8List? _convertYUV420ToNV21(CameraImage image) {
    try {
      final width = image.width;
      final height = image.height;

      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final out = Uint8List(width * height + (width * height ~/ 2));

      int index = 0;

      for (int y = 0; y < height; y++) {
        final yRow = y * yPlane.bytesPerRow;
        for (int x = 0; x < width; x++) {
          out[index++] = yPlane.bytes[yRow + x];
        }
      }

      final uvRowStride = uPlane.bytesPerRow;
      final uvPixelStride = uPlane.bytesPerPixel ?? 1;

      for (int y = 0; y < height ~/ 2; y++) {
        for (int x = 0; x < width ~/ 2; x++) {
          final uvIndex = y * uvRowStride + x * uvPixelStride;

          if (uvIndex >= vPlane.bytes.length ||
              uvIndex >= uPlane.bytes.length) {
            return null;
          }

          out[index++] = vPlane.bytes[uvIndex];
          out[index++] = uPlane.bytes[uvIndex];
        }
      }

      return out;
    } catch (e) {
      debugPrint('YUV420 to NV21 conversion error: $e');
      return null;
    }
  }

  void dispose() {
    _detector.close();
  }
}