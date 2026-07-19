import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bellspalsy_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:bellspalsy_app/app/modules/detection/models/detection_face_status.dart';
import 'package:bellspalsy_app/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Size;
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

  DetectionFaceStatus _evaluateFaces(List<Face> faces, double imageWidth) {
    if (faces.isEmpty) {
      return DetectionFaceStatus.noFace;
    }

    if (faces.length > 1) {
      return DetectionFaceStatus.multipleFaces;
    }

    final Face face = faces.first;
    final double faceWidthRatio = face.boundingBox.width / imageWidth;

    if (faceWidthRatio < 0.28) {
      return DetectionFaceStatus.tooFar;
    }

    if (faceWidthRatio > 0.75) {
      return DetectionFaceStatus.tooClose;
    }

    final double yaw = face.headEulerAngleY ?? 0.0;
    final double roll = face.headEulerAngleZ ?? 0.0;

    if (yaw.abs() > 12.0 || roll.abs() > 10.0) {
      return DetectionFaceStatus.headNotFrontal;
    }

    return DetectionFaceStatus.valid;
  }

  Future<DetectionFaceStatus?> processImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_busy) return null;
    _busy = true;

    try {
      final InputImage? inputImage = _toInputImage(image, camera);

      if (inputImage == null) {
        return DetectionFaceStatus.noFace;
      }

      final List<Face> faces = await _detector.processImage(inputImage);

      return _evaluateFaces(faces, image.width.toDouble());
    } catch (error, stackTrace) {
      debugPrint('ML Kit stream error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return DetectionFaceStatus.noFace;
    } finally {
      _busy = false;
    }
  }

  Future<DetectionFaceStatus> processCapturedFile(XFile file) async {
    if (_busy) {
      return DetectionFaceStatus.noFace;
    }

    _busy = true;

    try {
      final Uint8List bytes = await file.readAsBytes();

      if (bytes.isEmpty) {
        return DetectionFaceStatus.noFace;
      }

      final ui.Codec codec = await ui.instantiateImageCodec(bytes);

      final ui.FrameInfo frameInfo = await codec.getNextFrame();

      final double imageWidth = frameInfo.image.width.toDouble();

      frameInfo.image.dispose();
      codec.dispose();

      final InputImage inputImage = InputImage.fromFilePath(file.path);

      final List<Face> faces = await _detector.processImage(inputImage);

      return _evaluateFaces(faces, imageWidth);
    } catch (error, stackTrace) {
      debugPrint('ML Kit captured file error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return DetectionFaceStatus.noFace;
    } finally {
      _busy = false;
    }
  }

  Future<Map<String, dynamic>> analyzeBellPalsy(
    Map<String, List<String>> frames, {
    String mode = 'quick',
  }) async {
    final String token = AuthController.to.token.value;

    final http.Response response = await http.post(
      ApiService.uri('/api/detection/analyze'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'frames': frames, 'mode': mode}),
    );

    final String contentType = response.headers['content-type'] ?? '';

    if (!contentType.toLowerCase().contains('application/json')) {
      throw Exception('Respons server bukan JSON: ${response.body}');
    }

    final dynamic decodedBody = jsonDecode(response.body);

    if (decodedBody is! Map<String, dynamic>) {
      throw Exception('Format respons server tidak valid.');
    }

    final Map<String, dynamic> body = decodedBody;

    if (response.statusCode == 200 && body['success'] == true) {
      final dynamic data = body['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception('Data hasil analisis tidak valid.');
      }

      return Map<String, dynamic>.from(data);
    }

    throw Exception(
      body['message'] ??
          'Gagal menganalisis wajah. '
              'Status: ${response.statusCode}',
    );
  }

  InputImage? _toInputImage(CameraImage image, CameraDescription camera) {
    final InputImageRotation? rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );

    if (rotation == null) {
      debugPrint('Invalid rotation: ${camera.sensorOrientation}');
      return null;
    }

    final Size size = Size(image.width.toDouble(), image.height.toDouble());

    if (Platform.isAndroid) {
      if (image.planes.length < 3) {
        return null;
      }

      if (image.format.group != ImageFormatGroup.yuv420) {
        return null;
      }

      final Uint8List? nv21Bytes = _convertYUV420ToNV21(image);

      if (nv21Bytes == null) {
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
        return null;
      }

      if (image.format.group != ImageFormatGroup.bgra8888) {
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

    return null;
  }

  Uint8List? _convertYUV420ToNV21(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;

      final Plane yPlane = image.planes[0];
      final Plane uPlane = image.planes[1];
      final Plane vPlane = image.planes[2];

      final Uint8List output = Uint8List(
        width * height + (width * height ~/ 2),
      );

      int outputIndex = 0;

      for (int y = 0; y < height; y++) {
        final int yRow = y * yPlane.bytesPerRow;

        for (int x = 0; x < width; x++) {
          final int sourceIndex = yRow + x;

          if (sourceIndex >= yPlane.bytes.length) {
            return null;
          }

          output[outputIndex++] = yPlane.bytes[sourceIndex];
        }
      }

      final int uRowStride = uPlane.bytesPerRow;
      final int vRowStride = vPlane.bytesPerRow;

      final int uPixelStride = uPlane.bytesPerPixel ?? 1;
      final int vPixelStride = vPlane.bytesPerPixel ?? 1;

      for (int y = 0; y < height ~/ 2; y++) {
        for (int x = 0; x < width ~/ 2; x++) {
          final int uIndex = y * uRowStride + x * uPixelStride;

          final int vIndex = y * vRowStride + x * vPixelStride;

          if (uIndex >= uPlane.bytes.length ||
              vIndex >= vPlane.bytes.length ||
              outputIndex + 1 >= output.length) {
            return null;
          }

          // NV21: V lalu U.
          output[outputIndex++] = vPlane.bytes[vIndex];

          output[outputIndex++] = uPlane.bytes[uIndex];
        }
      }

      return output;
    } catch (error, stackTrace) {
      debugPrint('YUV420 to NV21 conversion error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  void dispose() {
    _detector.close();
  }
}
