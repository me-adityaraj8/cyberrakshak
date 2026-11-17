import 'dart:convert';
import 'dart:math' as math;

import 'featurizer.dart';

/// Logistic-regression scam classifier trained by ml/train.py.
/// Pure Dart: no ML runtime, works offline on Android and on the web.
class ScamModel {
  ScamModel({
    required this.bias,
    required this.weights,
    this.metrics = const {},
  });

  final double bias;
  final Map<int, double> weights;
  final Map<String, dynamic> metrics;

  factory ScamModel.fromJson(String source) {
    final j = jsonDecode(source) as Map<String, dynamic>;
    final raw = j['weights'] as Map<String, dynamic>;
    return ScamModel(
      bias: (j['bias'] as num).toDouble(),
      weights: {
        for (final e in raw.entries)
          int.parse(e.key): (e.value as num).toDouble(),
      },
      metrics: (j['metrics'] as Map<String, dynamic>?) ?? const {},
    );
  }

  /// Raw log-odds that [text] is a scam.
  double logit(String text) {
    final ids = Featurizer.bucketIds(text);
    if (ids.isEmpty) return bias;
    final v = 1 / math.sqrt(ids.length);
    var z = bias;
    for (final i in ids) {
      z += (weights[i] ?? 0) * v;
    }
    return z;
  }

  double probability(String text) => sigmoid(logit(text));

  static double sigmoid(double z) => 1 / (1 + math.exp(-z));
}
