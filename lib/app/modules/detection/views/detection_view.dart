import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:bellspalsy_app/app/modules/detection/models/detection_face_status.dart';
import 'package:bellspalsy_app/app/modules/detection/views/detection_result_view.dart';
import 'package:bellspalsy_app/services/face_detection_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

enum DetectionMode {
  quick,
  monitoring,
}

class DetectionView extends StatefulWidget {
  final DetectionMode mode;

  const DetectionView({
    super.key,
    this.mode = DetectionMode.quick,
  });

  @override
  State<DetectionView> createState() =>
      _DetectionViewState();
}

class _DetectionViewState
    extends State<DetectionView> {
  final FaceDetectionService _faceService =
      FaceDetectionService();

  CameraController? _controller;
  List<CameraDescription>? _cameras;

  bool _isCameraInitialized = false;
  bool _isFrontCamera = true;
  bool _isRecording = false;
  bool _isCleaningUp = false;
  bool _isNavigating = false;
  bool _isProcessing = false;
  bool _isInitializingCamera = false;
  bool _isCapturingFrame = false;
  bool _isAnalyzing = false;
  bool _isAbortingRecording = false;

  DetectionFaceStatus _faceStatus =
      DetectionFaceStatus.initializing;

  int _currentStep = 0;
  int _remainingSeconds = _totalSeconds;

  Timer? _timer;
  DateTime? _recordingStartedAt;

  static const int _secondsPerStep = 5;
  static const int _transitionMilliseconds = 1000;
  static const int _targetFramesPerStep = 6;
  static const int _minimumFramesPerStep = 4;
  static const int _totalSteps = 6;

  static const int _totalSeconds =
      _secondsPerStep * _totalSteps;

  final List<String> movementKeys = const [
    'diam',
    'angkat_alis',
    'tutup_mata',
    'senyum',
    'snarl',
    'mencucu',
  ];

  final Map<String, List<String>>
      _recordedFrames = {
    'diam': [],
    'angkat_alis': [],
    'tutup_mata': [],
    'senyum': [],
    'snarl': [],
    'mencucu': [],
  };

  final List<String> instructions = const [
    'Rilekskan wajah dan pandang lurus ke kamera',
    'Angkat kedua alis',
    'Tutup kedua mata secara perlahan',
    'Tersenyum dengan mulut terbuka',
    'Angkat bibir atas dan kerutkan hidung',
    'Mencucu atau majukan bibir',
  ];

  final List<Color> stepColors = const [
    Color(0xFF60A5FA),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFF97316),
    Color(0xFFEC4899),
    Color(0xFFA78BFA),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  bool get _isFaceValid =>
      _faceStatus == DetectionFaceStatus.valid;

  String get _faceMessage {
    switch (_faceStatus) {
      case DetectionFaceStatus.initializing:
        return 'Menyiapkan kamera...';

      case DetectionFaceStatus.noFace:
        return 'Wajah tidak terdeteksi. '
            'Arahkan wajah ke kamera.';

      case DetectionFaceStatus.multipleFaces:
        return 'Terdapat lebih dari satu wajah. '
            'Pastikan hanya satu orang di depan kamera.';

      case DetectionFaceStatus.tooFar:
        return 'Dekatkan wajah sedikit ke kamera.';

      case DetectionFaceStatus.tooClose:
        return 'Jauhkan wajah sedikit dari kamera.';

      case DetectionFaceStatus.headNotFrontal:
        return 'Hadapkan dan luruskan kepala ke kamera.';

      case DetectionFaceStatus.valid:
        return _isRecording
            ? 'Pertahankan wajah di dalam frame.'
            : 'Wajah terdeteksi. '
                'Silakan mulai perekaman.';
    }
  }

  Color get _faceStatusColor {
    switch (_faceStatus) {
      case DetectionFaceStatus.valid:
        return const Color(0xFF22C55E);

      case DetectionFaceStatus.noFace:
      case DetectionFaceStatus.multipleFaces:
        return const Color(0xFFEF4444);

      case DetectionFaceStatus.tooFar:
      case DetectionFaceStatus.tooClose:
      case DetectionFaceStatus.headNotFrontal:
        return const Color(0xFFF59E0B);

      case DetectionFaceStatus.initializing:
        return const Color(0xFFFBBF24);
    }
  }

  Future<void> _initializeCamera() async {
    if (_isInitializingCamera ||
        _isCleaningUp) {
      return;
    }

    _isInitializingCamera = true;

    try {
      final PermissionStatus status =
          await Permission.camera.request();

      if (!status.isGranted) {
        if (!mounted) return;

        setState(() {
          _faceStatus =
              DetectionFaceStatus.noFace;
          _isCameraInitialized = false;
        });

        return;
      }

      _cameras = await availableCameras();

      if (_cameras == null ||
          _cameras!.isEmpty) {
        if (!mounted) return;

        setState(() {
          _faceStatus =
              DetectionFaceStatus.noFace;
          _isCameraInitialized = false;
        });

        return;
      }

      await _startCamera();
    } catch (error, stackTrace) {
      debugPrint(
        'initializeCamera error: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _faceStatus =
            DetectionFaceStatus.noFace;
        _isCameraInitialized = false;
      });
    } finally {
      _isInitializingCamera = false;
    }
  }

  Future<void> _startCamera() async {
    if (_cameras == null ||
        _cameras!.isEmpty ||
        _isCleaningUp) {
      return;
    }

    final int cameraIndex =
        _pickCameraIndex(
      front: _isFrontCamera,
      cameras: _cameras!,
    );

    final CameraDescription selectedCamera =
        _cameras![cameraIndex];

    final CameraController controller =
        CameraController(
      selectedCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup:
          defaultTargetPlatform ==
                  TargetPlatform.iOS
              ? ImageFormatGroup.bgra8888
              : ImageFormatGroup.yuv420,
    );

    try {
      _isProcessing = false;

      await controller.initialize();

      if (!mounted || _isCleaningUp) {
        await controller.dispose();
        return;
      }

      _controller = controller;

      setState(() {
        _isCameraInitialized = true;
        _faceStatus =
            DetectionFaceStatus.initializing;
      });

      await controller.startImageStream(
        (CameraImage image) async {
          if (!mounted ||
              _isCleaningUp ||
              _isProcessing ||
              _isRecording) {
            return;
          }

          _isProcessing = true;

          try {
            final DetectionFaceStatus? result =
                await _faceService.processImage(
              image,
              selectedCamera,
            );

            if (!mounted ||
                _isCleaningUp ||
                result == null) {
              return;
            }

            setState(() {
              _faceStatus = result;
            });
          } catch (error, stackTrace) {
            debugPrint(
              'Face stream error: $error',
            );
            debugPrintStack(
              stackTrace: stackTrace,
            );

            if (!mounted ||
                _isCleaningUp) {
              return;
            }

            setState(() {
              _faceStatus =
                  DetectionFaceStatus.noFace;
            });
          } finally {
            _isProcessing = false;
          }
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        'startCamera error: $error',
      );
      debugPrintStack(stackTrace: stackTrace);

      try {
        await controller.dispose();
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = false;
        _faceStatus =
            DetectionFaceStatus.noFace;
      });
    }
  }

  int _pickCameraIndex({
    required bool front,
    required List<CameraDescription> cameras,
  }) {
    final CameraLensDirection target =
        front
            ? CameraLensDirection.front
            : CameraLensDirection.back;

    final int index = cameras.indexWhere(
      (camera) =>
          camera.lensDirection == target,
    );

    return index == -1 ? 0 : index;
  }

  Future<void> _toggleCamera() async {
    if (_cameras == null ||
        _cameras!.length < 2 ||
        _isRecording ||
        _isCleaningUp ||
        _isInitializingCamera) {
      return;
    }

    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isCameraInitialized = false;
      _faceStatus =
          DetectionFaceStatus.initializing;
    });

    await _cleanupCamera(
      keepFaceService: true,
    );

    if (!mounted) return;
    await _startCamera();
  }

  void _toggleRecord() {
    if (_isRecording) {
      _stopRecording();
      return;
    }

    if (_isFaceValid) {
      _startRecording();
    }
  }

  void _clearRecordedFrames() {
    for (final String key
        in movementKeys) {
      _recordedFrames[key]?.clear();
    }
  }

  Future<void> _startRecording() async {
    if (_isRecording ||
        !_isFaceValid ||
        _controller == null) {
      return;
    }

    try {
      if (_controller!
          .value.isStreamingImages) {
        await _controller!
            .stopImageStream();
      }
    } catch (error) {
      debugPrint(
        'stop stream before '
        'recording error: $error',
      );
    }

    _clearRecordedFrames();
    _recordingStartedAt = DateTime.now();

    if (!mounted) return;

    setState(() {
      _isRecording = true;
      _currentStep = 0;
      _remainingSeconds =
          _totalSeconds;
    });

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(milliseconds: 250),
      (Timer timer) async {
        if (!mounted ||
            !_isRecording ||
            _recordingStartedAt == null ||
            _isAbortingRecording) {
          return;
        }

        final int elapsedMilliseconds =
            DateTime.now()
                .difference(
                  _recordingStartedAt!,
                )
                .inMilliseconds;

        final int totalMilliseconds =
            _totalSeconds * 1000;

        if (elapsedMilliseconds >=
            totalMilliseconds) {
          await _stopRecording(
            goToResult: true,
          );
          return;
        }

        final int elapsedSeconds =
            elapsedMilliseconds ~/ 1000;

        final int newStep =
            (elapsedSeconds ~/
                    _secondsPerStep)
                .clamp(
                  0,
                  _totalSteps - 1,
                )
                .toInt();

        final int newRemaining =
            (_totalSeconds -
                    elapsedSeconds)
                .clamp(
                  0,
                  _totalSeconds,
                )
                .toInt();

        if (mounted) {
          setState(() {
            _currentStep = newStep;
            _remainingSeconds =
                newRemaining;
          });
        }

        final int
            stepElapsedMilliseconds =
            elapsedMilliseconds %
                (_secondsPerStep * 1000);

        // Detik pertama untuk membentuk ekspresi.
        if (stepElapsedMilliseconds <
            _transitionMilliseconds) {
          return;
        }

        final String movement =
            movementKeys[newStep];

        final int currentCount =
            _recordedFrames[movement]
                    ?.length ??
                0;

        if (currentCount >=
            _targetFramesPerStep) {
          return;
        }

        final int captureDuration =
            (_secondsPerStep * 1000) -
                _transitionMilliseconds;

        final int capturePosition =
            stepElapsedMilliseconds -
                _transitionMilliseconds;

        final int expectedFrameCount =
            (((capturePosition *
                            _targetFramesPerStep) ~/
                        captureDuration)
                    .clamp(
                      0,
                      _targetFramesPerStep -
                          1,
                    )
                    .toInt()) +
                1;

        if (currentCount <
            expectedFrameCount) {
          await _captureCurrentStepFrame();
        }
      },
    );
  }

  String _statusMessage(
    DetectionFaceStatus status,
  ) {
    switch (status) {
      case DetectionFaceStatus.noFace:
        return 'Wajah menghilang dari kamera.';

      case DetectionFaceStatus.multipleFaces:
        return 'Terdeteksi lebih dari satu wajah.';

      case DetectionFaceStatus.tooFar:
        return 'Wajah terlalu jauh dari kamera.';

      case DetectionFaceStatus.tooClose:
        return 'Wajah terlalu dekat dengan kamera.';

      case DetectionFaceStatus.headNotFrontal:
        return 'Posisi kepala tidak lurus.';

      case DetectionFaceStatus.initializing:
        return 'Kamera belum siap.';

      case DetectionFaceStatus.valid:
        return 'Wajah valid.';
    }
  }

  Future<void>
      _abortRecordingBecauseFaceInvalid(
    DetectionFaceStatus status,
  ) async {
    if (_isAbortingRecording) return;

    _isAbortingRecording = true;
    _timer?.cancel();
    _timer = null;
    _recordingStartedAt = null;
    _clearRecordedFrames();

    if (mounted) {
      setState(() {
        _isRecording = false;
        _currentStep = 0;
        _remainingSeconds =
            _totalSeconds;
        _faceStatus = status;
      });
    }

    Get.snackbar(
      'Perekaman diulang',
      '${_statusMessage(status)} '
          'Posisikan wajah kembali, '
          'kemudian mulai dari awal.',
      snackPosition:
          SnackPosition.BOTTOM,
      backgroundColor:
          Colors.red.withOpacity(0.88),
      colorText: Colors.white,
      duration:
          const Duration(seconds: 4),
    );

    await _restartCameraAfterFailure();
    _isAbortingRecording = false;
  }

  Future<void>
      _restartCameraAfterFailure() async {
    await _cleanupCamera(
      keepFaceService: true,
    );

    if (!mounted) return;

    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    );

    if (!mounted) return;
    await _startCamera();
  }

  Future<void> _captureCurrentStepFrame()
      async {
    if (_isCapturingFrame ||
        _isAbortingRecording ||
        !_isRecording ||
        _controller == null ||
        !_controller!.value.isInitialized ||
        _currentStep < 0 ||
        _currentStep >=
            movementKeys.length) {
      return;
    }

    final String movement =
        movementKeys[_currentStep];

    final int currentCount =
        _recordedFrames[movement]
                ?.length ??
            0;

    if (currentCount >=
        _targetFramesPerStep) {
      return;
    }

    _isCapturingFrame = true;

    try {
      final XFile file =
          await _controller!
              .takePicture();

      final DetectionFaceStatus status =
          await _faceService
              .processCapturedFile(file);

      if (status !=
          DetectionFaceStatus.valid) {
        await _abortRecordingBecauseFaceInvalid(
          status,
        );
        return;
      }

      if (!_isRecording ||
          _isAbortingRecording) {
        return;
      }

      final Uint8List bytes =
          await file.readAsBytes();

      final String base64Image =
          base64Encode(bytes);

      _recordedFrames[movement]!.add(
        base64Image,
      );

      debugPrint(
        'Captured $movement: '
        '${_recordedFrames[movement]!.length}'
        '/$_targetFramesPerStep',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'capture frame error: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (_isRecording &&
          !_isAbortingRecording) {
        await _abortRecordingBecauseFaceInvalid(
          DetectionFaceStatus.noFace,
        );
      }
    } finally {
      _isCapturingFrame = false;
    }
  }

  List<String>
      _findIncompleteMovements() {
    return movementKeys.where(
      (String movement) =>
          (_recordedFrames[movement]
                      ?.length ??
                  0) <
              _minimumFramesPerStep,
    ).toList();
  }

  Future<void> _stopRecording({
    bool goToResult = false,
  }) async {
    _timer?.cancel();
    _timer = null;
    _recordingStartedAt = null;

    if (!mounted) return;

    setState(() {
      _isRecording = false;
    });

    if (!goToResult ||
        _isNavigating ||
        _isAbortingRecording) {
      return;
    }

    final List<String>
        incompleteMovements =
        _findIncompleteMovements();

    if (incompleteMovements.isNotEmpty) {
      Get.snackbar(
        'Perekaman belum lengkap',
        'Frame belum cukup pada: '
            '${incompleteMovements.join(", ")}. '
            'Silakan ulangi dari awal.',
        snackPosition:
            SnackPosition.BOTTOM,
        backgroundColor:
            Colors.red.withOpacity(0.88),
        colorText: Colors.white,
      );

      _clearRecordedFrames();
      await _restartCameraAfterFailure();
      return;
    }

    _isNavigating = true;

    try {
      setState(() {
        _isAnalyzing = true;
      });

      final Map<String, dynamic> result =
          await _faceService
              .analyzeBellPalsy(
        _recordedFrames,
        mode: widget.mode ==
                DetectionMode.monitoring
            ? 'monitoring'
            : 'quick',
      );

      final String qualityStatus =
          (result['quality_status'] ??
                  'invalid')
              .toString();

      if (qualityStatus != 'valid') {
        final List<dynamic>
            invalidMovements =
            result['invalid_movements']
                    is List
                ? List<dynamic>.from(
                    result[
                        'invalid_movements'],
                  )
                : <dynamic>[];

        final String extraMessage =
            invalidMovements.isEmpty
                ? ''
                : ' Gerakan yang perlu '
                    'diulang: '
                    '${invalidMovements.join(", ")}.';

        Get.snackbar(
          'Pengukuran tidak dapat dinilai',
          'Ikuti seluruh gerakan dengan '
              'jelas dan pertahankan posisi '
              'wajah.$extraMessage',
          snackPosition:
              SnackPosition.BOTTOM,
          backgroundColor:
              Colors.orange
                  .withOpacity(0.92),
          colorText: Colors.white,
          duration:
              const Duration(seconds: 5),
        );

        _clearRecordedFrames();

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
          });
        }

        await _restartCameraAfterFailure();
        return;
      }

      await _cleanupCamera(
        keepFaceService: true,
      );

      await Future<void>.delayed(
        const Duration(
          milliseconds: 200,
        ),
      );

      if (!mounted) return;

      await Get.to(
        () => const DetectionResultView(),
        arguments: {
          ...result,
          'mode': widget.mode ==
                  DetectionMode.monitoring
              ? 'monitoring'
              : 'quick',
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        'analyze result error: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      Get.snackbar(
        'Gagal analisis',
        'Terjadi kesalahan saat '
            'mengirim data ke server.',
        snackPosition:
            SnackPosition.BOTTOM,
        backgroundColor:
            Colors.red.withOpacity(0.85),
        colorText: Colors.white,
      );

      await _restartCameraAfterFailure();
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }

      _isNavigating = false;
    }
  }

  Future<void> _cleanupCamera({
    bool keepFaceService = false,
  }) async {
    if (_isCleaningUp) return;
    _isCleaningUp = true;

    _timer?.cancel();
    _timer = null;
    _isProcessing = false;

    if (mounted) {
      setState(() {
        _isCameraInitialized = false;
        _isRecording = false;
      });
    }

    final CameraController?
        oldController = _controller;

    _controller = null;

    try {
      if (oldController != null &&
          oldController
              .value.isStreamingImages) {
        await oldController
            .stopImageStream();
      }
    } catch (error) {
      debugPrint(
        'stopImageStream error: $error',
      );
    }

    try {
      await oldController?.dispose();
    } catch (error) {
      debugPrint(
        'dispose camera error: $error',
      );
    }

    if (!keepFaceService) {
      _faceService.dispose();
    }

    _isCleaningUp = false;
  }

  Future<void> _handleBack() async {
    await _cleanupCamera();
    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    );

    if (mounted) {
      Get.back();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    final CameraController?
        oldController = _controller;

    _controller = null;

    try {
      if (oldController != null &&
          oldController
              .value.isStreamingImages) {
        oldController.stopImageStream();
      }
    } catch (_) {}

    try {
      oldController?.dispose();
    } catch (_) {}

    _faceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int safeStep = _currentStep
        .clamp(
          0,
          stepColors.length - 1,
        )
        .toInt();

    final Color currentColor =
        stepColors[safeStep];

    final bool canShowPreview =
        _isCameraInitialized &&
            _controller != null &&
            _controller!
                .value.isInitialized &&
            !_isCleaningUp;

    return Scaffold(
      backgroundColor: Colors.black,
      body: canShowPreview
          ? Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: OverflowBox(
                      alignment:
                          Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller!
                              .value
                              .previewSize!
                              .height,
                          height: _controller!
                              .value
                              .previewSize!
                              .width,
                          child:
                              CameraPreview(
                            _controller!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration:
                          BoxDecoration(
                        gradient:
                            LinearGradient(
                          begin:
                              Alignment.topCenter,
                          end: Alignment
                              .bottomCenter,
                          colors: [
                            Colors.black
                                .withOpacity(
                              0.35,
                            ),
                            Colors.transparent,
                            Colors.black
                                .withOpacity(
                              0.55,
                            ),
                          ],
                          stops: const [
                            0.0,
                            0.55,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: _FaceGuide(
                    color: _isRecording
                        ? currentColor
                            .withOpacity(0.95)
                        : _faceStatusColor
                            .withOpacity(0.85),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      14,
                      10,
                      14,
                      0,
                    ),
                    child: Row(
                      children: [
                        _GlassIconButton(
                          icon: Icons
                              .arrow_back_ios_new_rounded,
                          onTap:
                              _handleBack,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: _GlassPill(
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration:
                                      BoxDecoration(
                                    color: _isRecording
                                        ? const Color(
                                            0xFFEF4444,
                                          )
                                        : _faceStatusColor,
                                    shape:
                                        BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  _isRecording
                                      ? 'Recording'
                                      : (_isFaceValid
                                          ? 'Ready'
                                          : 'Waiting'),
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                    fontSize:
                                        12.5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Front: '
                                  '${_isFrontCamera ? "ON" : "OFF"}',
                                  style:
                                      TextStyle(
                                    color: Colors.white
                                        .withOpacity(
                                      0.75,
                                    ),
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  top: 90,
                  child: _GlassCard(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        14,
                        12,
                        14,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              _SmallChip(
                                text: _isRecording
                                    ? '$_remainingSeconds detik'
                                    : 'Siap deteksi',
                                icon: _isRecording
                                    ? Icons
                                        .timer_outlined
                                    : Icons
                                        .verified_user_outlined,
                              ),
                              const Spacer(),
                              _StepDots(
                                count:
                                    instructions
                                        .length,
                                current:
                                    _currentStep,
                                activeColor:
                                    currentColor,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            _faceMessage,
                            style:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 14.5,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              height: 1.2,
                            ),
                          ),
                          if (_isRecording) ...[
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              'Langkah '
                              '${_currentStep + 1}/'
                              '${instructions.length}',
                              style:
                                  TextStyle(
                                color: Colors.white
                                    .withOpacity(
                                  0.85,
                                ),
                                fontWeight:
                                    FontWeight
                                        .w800,
                                fontSize:
                                    12.5,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              instructions[
                                  _currentStep],
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 15.5,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                999,
                              ),
                              child:
                                  LinearProgressIndicator(
                                value: (_totalSeconds -
                                        _remainingSeconds) /
                                    _totalSeconds,
                                backgroundColor:
                                    Colors.white
                                        .withOpacity(
                                  0.18,
                                ),
                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  currentColor,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        18,
                        10,
                        18,
                        18,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          _GlassIconButton(
                            icon: Icons
                                .flip_camera_ios_rounded,
                            onTap:
                                _toggleCamera,
                            disabled:
                                _isRecording,
                          ),
                          _RecordButton(
                            isRecording:
                                _isRecording,
                            ringColor:
                                _isRecording
                                    ? const Color(
                                        0xFFEF4444,
                                      )
                                    : (_isFaceValid
                                        ? Colors
                                            .white
                                        : Colors
                                            .white38),
                            onTap:
                                _toggleRecord,
                            disabled:
                                !_isRecording &&
                                    !_isFaceValid,
                          ),
                          _GlassIconButton(
                            icon: Icons
                                .help_outline_rounded,
                            onTap: () async {
                              await showModalBottomSheet<
                                  void>(
                                context:
                                    context,
                                backgroundColor:
                                    Colors
                                        .transparent,
                                isScrollControlled:
                                    true,
                                builder: (_) =>
                                    const _HelpSheet(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isAnalyzing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.65),
                      child:
                          const Center(
                        child: Column(
                          mainAxisSize:
                              MainAxisSize
                                  .min,
                          children: [
                            CircularProgressIndicator(
                              color:
                                  Colors.white,
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'Sedang menganalisis '
                              'wajah...',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child:
                  CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(0.12),
            border: Border.all(
              color: Colors.white
                  .withOpacity(0.14),
            ),
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final Widget child;

  const _GlassPill({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12,
          sigmaY: 12,
        ),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(0.10),
            border: Border.all(
              color: Colors.white
                  .withOpacity(0.14),
            ),
            borderRadius:
                BorderRadius.circular(999),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassIconButton
    extends StatelessWidget {
  final IconData icon;
  final Future<void> Function()? onTap;
  final bool disabled;

  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: disabled || onTap == null
          ? null
          : () => onTap!(),
      borderRadius:
          BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(
                disabled ? 0.06 : 0.10,
              ),
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.14),
              ),
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white
                  .withOpacity(
                disabled ? 0.40 : 0.95,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _SmallChip({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(999),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white
                .withOpacity(0.90),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const _StepDots({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          List<Widget>.generate(
        count,
        (int index) {
          final bool active =
              index == current;

          return AnimatedContainer(
            duration: const Duration(
              milliseconds: 220,
            ),
            margin:
                const EdgeInsets.only(
              left: 6,
            ),
            width: active ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: active
                  ? activeColor
                  : Colors.white
                      .withOpacity(0.25),
              borderRadius:
                  BorderRadius.circular(
                999,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecordButton
    extends StatelessWidget {
  final bool isRecording;
  final Color ringColor;
  final VoidCallback onTap;
  final bool disabled;

  const _RecordButton({
    required this.isRecording,
    required this.ringColor,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(
            disabled ? 0.12 : 0.25,
          ),
          border: Border.all(
            color: ringColor,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.30),
              blurRadius: 18,
              offset:
                  const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 200,
            ),
            width: isRecording ? 28 : 46,
            height: isRecording ? 28 : 46,
            decoration: BoxDecoration(
              color: disabled
                  ? Colors.white38
                  : (isRecording
                      ? const Color(
                          0xFFEF4444,
                        )
                      : Colors.white),
              borderRadius:
                  BorderRadius.circular(
                isRecording ? 8 : 999,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaceGuide extends StatelessWidget {
  final Color color;

  const _FaceGuide({
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (
        BuildContext context,
        BoxConstraints constraints,
      ) {
        final double width =
            (constraints.maxWidth * 0.62)
                .clamp(
                  230.0,
                  300.0,
                )
                .toDouble();

        final double height =
            (width * 1.28)
                .clamp(
                  300.0,
                  360.0,
                )
                .toDouble();

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                      28,
                    ),
                    border: Border.all(
                      color: color
                          .withOpacity(
                        0.55,
                      ),
                      width: 2,
                    ),
                    color: Colors.black
                        .withOpacity(
                      0.05,
                    ),
                  ),
                ),
              ),
              _CornerMark(
                alignment:
                    Alignment.topLeft,
                color: color,
              ),
              _CornerMark(
                alignment:
                    Alignment.topRight,
                color: color,
              ),
              _CornerMark(
                alignment:
                    Alignment.bottomLeft,
                color: color,
              ),
              _CornerMark(
                alignment:
                    Alignment.bottomRight,
                color: color,
              ),
              Align(
                alignment:
                    Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.black
                          .withOpacity(
                        0.45,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        999,
                      ),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(
                          0.10,
                        ),
                      ),
                    ),
                    child: Text(
                      'Posisikan wajah '
                      'di dalam frame',
                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(
                          0.90,
                        ),
                        fontSize: 12.5,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CornerMark extends StatelessWidget {
  final Alignment alignment;
  final Color color;

  const _CornerMark({
    required this.alignment,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 22.0;
    const double thickness = 3.0;

    return Align(
      alignment: alignment,
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _CornerPainter(
              color: color,
              thickness: thickness,
              alignment: alignment,
            ),
          ),
        ),
      ),
    );
  }
}

class _CornerPainter
    extends CustomPainter {
  final Color color;
  final double thickness;
  final Alignment alignment;

  _CornerPainter({
    required this.color,
    required this.thickness,
    required this.alignment,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final Paint paint = Paint()
      ..color = color.withOpacity(0.95)
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();

    final bool isLeft =
        alignment.x < 0;
    final bool isTop =
        alignment.y < 0;

    if (isLeft && isTop) {
      path.moveTo(
        0,
        size.height * 0.7,
      );
      path.lineTo(0, 0);
      path.lineTo(
        size.width * 0.7,
        0,
      );
    } else if (!isLeft && isTop) {
      path.moveTo(
        size.width * 0.3,
        0,
      );
      path.lineTo(size.width, 0);
      path.lineTo(
        size.width,
        size.height * 0.7,
      );
    } else if (isLeft && !isTop) {
      path.moveTo(
        0,
        size.height * 0.3,
      );
      path.lineTo(0, size.height);
      path.lineTo(
        size.width * 0.7,
        size.height,
      );
    } else {
      path.moveTo(
        size.width * 0.3,
        size.height,
      );
      path.lineTo(
        size.width,
        size.height,
      );
      path.lineTo(
        size.width,
        size.height * 0.3,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}

class _HelpSheet extends StatelessWidget {
  const _HelpSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (
        BuildContext context,
        ScrollController controller,
      ) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                const BorderRadius
                    .vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.12),
                blurRadius: 18,
                offset:
                    const Offset(0, -8),
              ),
            ],
          ),
          child: ListView(
            controller: controller,
            padding:
                const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              18,
            ),
            children: const [
              Center(
                child: _DragHandle(),
              ),
              SizedBox(height: 14),
              Text(
                'Tips agar hasil baik',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
              SizedBox(height: 10),
              _HelpRow(
                icon:
                    Icons.lightbulb_outline,
                text:
                    'Gunakan tempat yang terang.',
              ),
              _HelpRow(
                icon:
                    Icons.face_6_outlined,
                text:
                    'Wajah lurus menghadap kamera.',
              ),
              _HelpRow(
                icon:
                    Icons.visibility_outlined,
                text:
                    'Lepas masker atau kacamata '
                    'bila menghalangi wajah.',
              ),
              _HelpRow(
                icon:
                    Icons.timer_outlined,
                text:
                    'Ikuti seluruh 6 instruksi '
                    'sampai selesai.',
              ),
              _HelpRow(
                icon:
                    Icons.restart_alt_rounded,
                text:
                    'Perekaman diulang dari awal '
                    'bila wajah menghilang atau '
                    'posisi tidak valid.',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius:
              BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HelpRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration:
                BoxDecoration(
              color: const Color(
                0xFF316B5C,
              ).withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color:
                  Color(0xFF316B5C),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black
                    .withOpacity(0.70),
                fontWeight:
                    FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
