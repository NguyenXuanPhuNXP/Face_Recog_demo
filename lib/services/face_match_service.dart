import 'dart:math';

import 'package:flutter/cupertino.dart';

class FaceMatchService {

  double cosineSimilarity(
      List<double> a,
      List<double> b,
      ) {
    if (a.length != b.length) {
      throw Exception(
        'Embedding size không giống nhau',
      );
    }

    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < a.length; i++) {

      dotProduct += a[i] * b[i];

      normA += a[i] * a[i];

      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) {
      return 0;
    }

    return dotProduct /
        (sqrt(normA) * sqrt(normB));
  }

  bool isMatch(
      List<double> registered,
      List<double> current,
      ) {
    final similarity =
    cosineSimilarity(
      registered,
      current,
    );

    debugPrint(
      'Cosine Similarity: $similarity',
    );

    return similarity >= 0.70;
  }
}