import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceEmbeddingService {
  late Interpreter _interpreter;

  Future<void> initialize() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/mobilefacenet.tflite',
    );

    debugPrint(
      'Input shape: '
          '${_interpreter.getInputTensor(0).shape}',
    );

    debugPrint(
      'Output shape: '
          '${_interpreter.getOutputTensor(0).shape}',
    );
  }

  List<double> generateEmbedding(
      img.Image face,
      ) {
    final resized = img.copyResize(
      face,
      width: 112,
      height: 112,
    );

    final input =
    List.generate(
      1,
          (_) => List.generate(
        112,
            (y) => List.generate(
          112,
              (x) {
            final pixel =
            resized.getPixel(x, y);

            return [
              (pixel.r / 127.5) - 1.0,
              (pixel.g / 127.5) - 1.0,
              (pixel.b / 127.5) - 1.0,
            ];
          },
        ),
      ),
    );

    final output =
    List.generate(
      1,
          (_) => List<double>.filled(
        192,
        0,
      ),
    );

    _interpreter.run(
      input,
      output,
    );

    return List<double>.from(
      output[0],
    );
  }

  void dispose() {
    _interpreter.close();
  }
}