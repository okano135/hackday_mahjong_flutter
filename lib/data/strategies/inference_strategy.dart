// lib/data/strategies/inference_strategy.dart
import 'package:camera/camera.dart';
import '../models/detection_result.dart';

/// 推論戦略のインターフェースを定義する抽象クラス
/// このインターフェースを実装することで、推論方法を簡単に入れ替えられる
abstract class InferenceStrategy {
  /// カメラ画像を受け取り、推論を実行して検出結果のリストを返す
  ///
  /// [image] カメラストリームから得られるCameraImage
  /// returns 検出結果のリスト (Future)
  Future<List<DetectionResult>> runInference(CameraImage image);

  /// このStrategyが使用するリソースを解放する
  /// (例: TFLiteモデルのInterpreterを閉じる)
  void dispose();
}
