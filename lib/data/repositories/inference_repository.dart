import 'package:camera/camera.dart';

import '../models/detection_result.dart';
import '../strategies/inference_strategy.dart';

/// 推論処理の窓口となるリポジトリ
///
/// UI層はこのリポジトリを通じて推論を実行する。
/// 内部でどの戦略(ローカル/API)を使うかは、外部から注入される
/// `InferenceStrategy`によって決定される。
class InferenceRepository {
  final InferenceStrategy _strategy;

  InferenceRepository(this._strategy);

  /// 現在の戦略で推論を実行する
  Future<List<DetectionResult>> runInference(CameraImage image) {
    return _strategy.runInference(image);
  }
}
