import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../services/face_detector_service.dart';
import '../services/face_crop_service.dart';
import '../services/face_embedding_service.dart';

class FaceCameraScreen extends StatefulWidget {

  const FaceCameraScreen({
    super.key,
  });

  @override
  State<FaceCameraScreen> createState() =>
      _FaceCameraScreenState();
}

class _FaceCameraScreenState
    extends State<FaceCameraScreen> {

  CameraController? _cameraController;

  final FaceDetectorService
  _faceDetector =
  FaceDetectorService();

  final FaceCropService
  _faceCrop =
  FaceCropService();

  final FaceEmbeddingService
  _embeddingService =
  FaceEmbeddingService();

  bool _loading = true;
  bool _processing = false;

  String _message =
      'Đưa khuôn mặt vào camera';

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  Future<void> _initialize() async {

    await _embeddingService.initialize();

    final cameras =
    await availableCameras();

    final frontCamera =
    cameras.firstWhere(
          (camera) =>
      camera.lensDirection ==
          CameraLensDirection.front,
    );

    _cameraController =
        CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _scanFace() async {

    if (_processing) {
      return;
    }

    if (_cameraController == null) {
      return;
    }

    setState(() {
      _processing = true;
      _message =
      'Đang chụp khuôn mặt...';
    });

    try {

      final XFile photo =
      await _cameraController!
          .takePicture();

      setState(() {
        _message =
        'Đang phát hiện khuôn mặt...';
      });

      final faces =
      await _faceDetector.detect(
        photo.path,
      );

      if (faces.isEmpty) {

        setState(() {
          _message =
          'Không tìm thấy khuôn mặt';
        });

        return;
      }

      if (faces.length > 1) {

        setState(() {
          _message =
          'Chỉ được có một khuôn mặt';
        });

        return;
      }

      final imageBytes =
      await File(photo.path)
          .readAsBytes();

      final original =
      img.decodeImage(
        imageBytes,
      );

      if (original == null) {
        throw Exception(
          'Không đọc được ảnh',
        );
      }

      final face =
          faces.first;

      setState(() {
        _message =
        'Đang tạo Face Embedding...';
      });

      final cropped =
      _faceCrop.cropFace(
        original,
        face,
      );

      final embedding =
      _embeddingService
          .generateEmbedding(
        cropped,
      );

      debugPrint(
        'Embedding length: '
            '${embedding.length}',
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        embedding,
      );

    } catch (e) {

      debugPrint(
        'Face error: $e',
      );

      setState(() {
        _message =
        'Có lỗi khi xử lý khuôn mặt';
      });

    } finally {

      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  @override
  void dispose() {

    _cameraController?.dispose();

    _faceDetector.dispose();

    _embeddingService.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    if (_loading) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Xác thực khuôn mặt',
        ),
      ),

      body: Column(
        children: [

          Expanded(
            child: Stack(
              alignment:
              Alignment.center,

              children: [

                CameraPreview(
                  _cameraController!,
                ),

                Container(
                  width: 250,
                  height: 320,

                  decoration:
                  BoxDecoration(
                    border:
                    Border.all(
                      color: Colors.white,
                      width: 3,
                    ),

                    borderRadius:
                    BorderRadius
                        .circular(
                      160,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.all(
              16,
            ),

            child: Text(
              _message,
              textAlign:
              TextAlign.center,

              style:
              const TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.all(
              16,
            ),

            child: SizedBox(
              width:
              double.infinity,

              child:
              ElevatedButton(
                onPressed:
                _processing
                    ? null
                    : _scanFace,

                child: Text(
                  _processing
                      ? 'Đang xử lý...'
                      : 'QUÉT KHUÔN MẶT',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}