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

  /// 14個のサンプル検出結果を生成する
  static List<DetectionResult> createRecommendSampleResults() {
    return [
      DetectionResult(
        boundingBox: const Rect.fromLTRB(100, 150, 180, 220),
        label: "Manzu1",
        confidence: 0.95,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(190, 150, 270, 220),
        label: "Manzu1",
        confidence: 0.92,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(280, 150, 360, 220),
        label: "Manzu2",
        confidence: 0.88,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(370, 150, 450, 220),
        label: "Manzu2",
        confidence: 0.91,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(460, 150, 540, 220),
        label: "Manzu3",
        confidence: 0.87,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(550, 150, 630, 220),
        label: "Manzu3",
        confidence: 0.93,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(100, 240, 180, 310),
        label: "Manzu4",
        confidence: 0.89,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(190, 240, 270, 310),
        label: "Manzu5",
        confidence: 0.94,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(280, 240, 360, 310),
        label: "Manzu6",
        confidence: 0.86,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(370, 240, 450, 310),
        label: "Manzu7",
        confidence: 0.96,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(460, 240, 540, 310),
        label: "Manzu8",
        confidence: 0.90,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(550, 240, 630, 310),
        label: "Souzu1",
        confidence: 0.85,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(100, 330, 180, 400),
        label: "Souzu1",
        confidence: 0.97,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(190, 330, 270, 400),
        label: "Souzu2",
        confidence: 0.84,
      ),
    ];
  }

  static List<DetectionResult> createScoreSampleResults() {
    return [
      DetectionResult(
        boundingBox: const Rect.fromLTRB(100, 150, 180, 220),
        label: "Manzu2",
        confidence: 0.95,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(190, 150, 270, 220),
        label: "Manzu3",
        confidence: 0.92,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(280, 150, 360, 220),
        label: "Pinzu4",
        confidence: 0.88,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(370, 150, 450, 220),
        label: "Pinzu5",
        confidence: 0.91,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(460, 150, 540, 220),
        label: "Pinzu6",
        confidence: 0.87,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(550, 150, 630, 220),
        label: "Pinzu6",
        confidence: 0.93,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(100, 240, 180, 310),
        label: "Pinzu7",
        confidence: 0.89,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(190, 240, 270, 310),
        label: "Pinzu8",
        confidence: 0.94,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(280, 240, 360, 310),
        label: "Souzu3",
        confidence: 0.86,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(370, 240, 450, 310),
        label: "Souzu4",
        confidence: 0.96,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(460, 240, 540, 310),
        label: "Souzu5",
        confidence: 0.90,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(550, 240, 630, 310),
        label: "Sha",
        confidence: 0.85,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(100, 330, 180, 400),
        label: "Sha",
        confidence: 0.97,
      ),
      DetectionResult(
        boundingBox: const Rect.fromLTRB(190, 330, 270, 400),
        label: "Manzu1",
        confidence: 0.84,
      ),
    ];
  }

  @override
  String toString() {
    return 'DetectionResult(label: $label, confidence: $confidence, box: $boundingBox)';
  }
}
