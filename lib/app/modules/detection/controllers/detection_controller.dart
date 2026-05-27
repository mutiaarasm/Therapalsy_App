import 'package:bellspalsy_app/app/modules/detection/models/detection_face_status.dart';
import 'package:bellspalsy_app/services/face_detection_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DetectionController extends GetxController {
  final FaceDetectionService service = FaceDetectionService();

  CameraController? cameraController;
  List<CameraDescription>? cameras;

  var isCameraInitialized = false.obs;
  var isFrontCamera = true.obs;
  var faceStatus = DetectionFaceStatus.initializing.obs;

  bool _isProcessing = false;

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras == null || cameras!.isEmpty) {
        faceStatus.value = DetectionFaceStatus.noFace;
        return;
      }

      await _startCamera();
    } catch (e) {
      debugPrint('initCamera error: $e');
      faceStatus.value = DetectionFaceStatus.noFace;
    }
  }

  Future<void> _startCamera() async {
    try {
      final camIndex = _pickCamera(isFrontCamera.value);

      cameraController = CameraController(
        cameras![camIndex],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: defaultTargetPlatform == TargetPlatform.iOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
      );

      await cameraController!.initialize();

      isCameraInitialized.value = true;
      faceStatus.value = DetectionFaceStatus.initializing;

      await cameraController!.startImageStream((image) async {
        if (_isProcessing) return;
        _isProcessing = true;

        try {
          final result = await service.processImage(
            image,
            cameras![camIndex],
          );

          faceStatus.value = result ?? DetectionFaceStatus.noFace;
        } catch (e) {
          debugPrint('startImageStream error: $e');
          faceStatus.value = DetectionFaceStatus.noFace;
        } finally {
          _isProcessing = false;
        }
      });
    } catch (e) {
      debugPrint('_startCamera error: $e');
      faceStatus.value = DetectionFaceStatus.noFace;
      isCameraInitialized.value = false;
    }
  }

  Future<void> switchCamera() async {
    try {
      await _stopCamera();
      isFrontCamera.value = !isFrontCamera.value;
      await _startCamera();
    } catch (e) {
      debugPrint('switchCamera error: $e');
      faceStatus.value = DetectionFaceStatus.noFace;
    }
  }

  Future<void> _stopCamera() async {
    try {
      if (cameraController != null &&
          cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }
    } catch (e) {
      debugPrint('stopImageStream error: $e');
    }

    try {
      await cameraController?.dispose();
    } catch (e) {
      debugPrint('dispose camera error: $e');
    }

    cameraController = null;
    isCameraInitialized.value = false;
    _isProcessing = false;
  }

  int _pickCamera(bool front) {
    final dir =
        front ? CameraLensDirection.front : CameraLensDirection.back;

    final idx = cameras!.indexWhere((c) => c.lensDirection == dir);
    return idx == -1 ? 0 : idx;
  }

  bool get isFaceValid =>
      faceStatus.value == DetectionFaceStatus.valid;

  @override
  void onClose() {
    _stopCamera();
    service.dispose();
    super.onClose();
  }
}