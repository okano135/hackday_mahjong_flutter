// lib/data/models/detection_result.dart
import 'dart:ui';

/// YOLOモデルからの単一の検出結果を表現するクラス
class DetectionResult {
  /// 検出領域のバウンディングボックス
  final Rect boundingBox;

  /// 検出されたクラスのラベル名 (例: "man1", "sou2")
  final String label;

  /// 検出の信頼度 (0.0 ~ 1.0)
  final double confidence;

  DetectionResult({
    required this.boundingBox,
    required this.label,
    required this.confidence,
  });

  @override
  String toString() {
    return 'DetectionResult(label: $label, confidence: $confidence, box: $boundingBox)';
  }
}
