// lib/data/strategies/local_inference_strategy.dart
import 'dart:async';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/detection_result.dart';
import 'inference_strategy.dart';

/// Isolateに渡す初期化データ
class IsolateInitData {
  final SendPort sendPort;
  final String modelPath;
  final String labelsPath;

  IsolateInitData(this.sendPort, this.modelPath, this.labelsPath);
}

/// Isolateに渡す推論用データ
class InferenceData {
  final CameraImage image;
  final Size screenPreviewSize;

  InferenceData(this.image, this.screenPreviewSize);
}

/// ローカルのTFLiteモデルを使って推論を実行する戦略
class LocalInferenceStrategy implements InferenceStrategy {
  late final Isolate _isolate;
  late final SendPort _isolateSendPort;
  final ReceivePort _receivePort = ReceivePort();
  final Completer<void> _isolateReadyCompleter = Completer<void>();

  LocalInferenceStrategy() {
    _initIsolate();
  }

  /// Isolateを初期化して双方向通信をセットアップする
  Future<void> _initIsolate() async {
    // Isolateの初期化データを準備
    final initData = IsolateInitData(
      _receivePort.sendPort,
      'assets/yolov8n_mahjong.tflite', // TODO: 自身のモデルパスに修正
      'assets/labels.txt', // TODO: 自身のラベルパスに修正
    );
    // Isolateを生成
    _isolate = await Isolate.spawn(_inferenceIsolateEntry, initData);

    // Isolateからの最初のメッセージ（SendPort）を待つ
    _isolateSendPort = await _receivePort.first;
    _isolateReadyCompleter.complete();
  }

  @override
  Future<List<DetectionResult>> runInference(CameraImage image) async {
    // Isolateの準備ができるまで待つ
    await _isolateReadyCompleter.future;

    // Isolateからの結果を待つためのCompleter
    final completer = Completer<List<DetectionResult>>();

    // 1回限りのリスナーをセットアップ
    final sub = _receivePort.listen((message) {
      if (message is List<DetectionResult>) {
        if (!completer.isCompleted) {
          completer.complete(message);
        }
      }
    });

    // Isolateに推論データを送信
    final inferenceData = InferenceData(
      image,
      Size(image.width.toDouble(), image.height.toDouble()),
    );
    _isolateSendPort.send(inferenceData);

    // 結果が返ってきたらリスナーをキャンセル
    final result = await completer.future;
    sub.cancel();
    return result;
  }

  @override
  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
  }
}

// --- Isolate内で実行されるコード ---

/// Isolateのエントリポイント
void _inferenceIsolateEntry(IsolateInitData initData) async {
  final port = ReceivePort();
  // メインスレッドにこのIsolateのSendPortを送信
  initData.sendPort.send(port.sendPort);

  // TFLiteモデルとラベルをロード
  final interpreter = await Interpreter.fromAsset(initData.modelPath);
  final labels = await _loadLabels(initData.labelsPath);

  // 入力と出力の形状を取得
  final inputShape = interpreter.getInputTensor(0).shape;
  final outputShape = interpreter.getOutputTensor(0).shape;
  final inputHeight = inputShape[1];
  final inputWidth = inputShape[2];

  // メインスレッドからのメッセージを待機
  await for (final InferenceData inferenceData in port) {
    // 前処理
    final image = _convertYUV420toImage(inferenceData.image);
    final resizedImage = img.copyResize(
      image,
      width: inputWidth,
      height: inputHeight,
    );
    final imageBytes = resizedImage.getBytes(order: img.ChannelOrder.rgb);
    final normalizedBytes = imageBytes.map((byte) => byte / 255.0).toList();
    // `List<double>` を `List<List<List<List<double>>>>` に変換
    final inputTensor = [
      [
        for (int y = 0; y < inputHeight; y++)
          [
            for (int x = 0; x < inputWidth; x++)
              [
                for (int c = 0; c < 3; c++)
                  normalizedBytes[(y * inputWidth + x) * 3 + c],
              ],
          ],
      ],
    ];

    // 出力テンソルを準備
    final outputTensor = {
      0: List.filled(
        outputShape.reduce((a, b) => a * b),
        0.0,
      ).reshape(outputShape),
    };

    // 推論実行
    interpreter.runForMultipleInputs([inputTensor], outputTensor);

    // 後処理
    final results = _processOutput(
      outputTensor[0]![0],
      labels,
      inferenceData.screenPreviewSize,
      Size(inputWidth.toDouble(), inputHeight.toDouble()),
    );

    // NMS (Non-Maximum Suppression)
    final nmsResults = _nonMaximumSuppression(results);

    // 結果をメインスレッドに送信
    initData.sendPort.send(nmsResults);
  }
}

/// ラベルファイルを読み込む
Future<List<String>> _loadLabels(String path) async {
  final labelsRaw = await rootBundle.loadString(path);
  return labelsRaw.split('\n').where((line) => line.isNotEmpty).toList();
}

/// YUV420形式をImageオブジェクトに変換
img.Image _convertYUV420toImage(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final yPlane = image.planes[0].bytes;
  final uPlane = image.planes[1].bytes;
  final vPlane = image.planes[2].bytes;
  final uvRowStride = image.planes[1].bytesPerRow;
  final uvPixelStride = image.planes[1].bytesPerPixel!;

  final convertedImage = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final yIndex = y * width + x;
      final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
      final yValue = yPlane[yIndex];
      final uValue = uPlane[uvIndex];
      final vValue = vPlane[uvIndex];
      final r = yValue + 1.402 * (vValue - 128);
      final g = yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128);
      final b = yValue + 1.772 * (uValue - 128);
      convertedImage.setPixelRgba(
        x,
        y,
        r.round().clamp(0, 255),
        g.round().clamp(0, 255),
        b.round().clamp(0, 255),
        255,
      );
    }
  }
  return convertedImage;
}

/// TFLiteの出力を解析してDetectionResultのリストに変換
List<DetectionResult> _processOutput(
  List<List<double>> output,
  List<String> labels,
  Size originalSize,
  Size modelSize,
) {
  final List<DetectionResult> results = [];
  const double confidenceThreshold = 0.5; // 信頼度の閾値

  // YOLOv8の出力形式 (1, 84, 8400) を想定し、転置 (transpose) する
  // (8400, 84) の形式に変換
  final List<List<double>> transposedOutput = List.generate(
    output[0].length,
    (i) => List.generate(output.length, (j) => output[j][i]),
  );

  for (final detection in transposedOutput) {
    final scores = detection.sublist(4);
    double maxScore = 0;
    int bestClassIndex = -1;

    for (int j = 0; j < scores.length; j++) {
      if (scores[j] > maxScore) {
        maxScore = scores[j];
        bestClassIndex = j;
      }
    }

    if (maxScore > confidenceThreshold) {
      final cx = detection[0];
      final cy = detection[1];
      final w = detection[2];
      final h = detection[3];

      // 元の画像サイズに座標をスケールアップ
      final scaleX = originalSize.width / modelSize.width;
      final scaleY = originalSize.height / modelSize.height;

      final left = (cx - w / 2) * scaleX;
      final top = (cy - h / 2) * scaleY;
      final width = w * scaleX;
      final height = h * scaleY;

      results.add(
        DetectionResult(
          boundingBox: Rect.fromLTWH(left, top, width, height),
          label: labels[bestClassIndex],
          confidence: maxScore,
        ),
      );
    }
  }
  return results;
}

/// NMS (Non-Maximum Suppression) を実行して重複したボックスを除去
List<DetectionResult> _nonMaximumSuppression(
  List<DetectionResult> boxes, {
  double iouThreshold = 0.4,
}) {
  if (boxes.isEmpty) return [];

  // 信頼度で降順にソート
  boxes.sort((a, b) => b.confidence.compareTo(a.confidence));

  final List<DetectionResult> selectedBoxes = [];
  final List<bool> isSuppressed = List.filled(boxes.length, false);

  for (int i = 0; i < boxes.length; i++) {
    if (isSuppressed[i]) continue;
    selectedBoxes.add(boxes[i]);
    for (int j = i + 1; j < boxes.length; j++) {
      if (isSuppressed[j]) continue;
      final iou = _calculateIoU(boxes[i].boundingBox, boxes[j].boundingBox);
      if (iou > iouThreshold) {
        isSuppressed[j] = true;
      }
    }
  }
  return selectedBoxes;
}

/// 2つの矩形のIoU (Intersection over Union) を計算
double _calculateIoU(Rect boxA, Rect boxB) {
  final intersectionX1 = boxA.left > boxB.left ? boxA.left : boxB.left;
  final intersectionY1 = boxA.top > boxB.top ? boxA.top : boxB.top;
  final intersectionX2 = boxA.right < boxB.right ? boxA.right : boxB.right;
  final intersectionY2 = boxA.bottom < boxB.bottom ? boxA.bottom : boxB.bottom;

  final intersectionWidth = intersectionX2 > intersectionX1
      ? intersectionX2 - intersectionX1
      : 0;
  final intersectionHeight = intersectionY2 > intersectionY1
      ? intersectionY2 - intersectionY1
      : 0;
  final intersectionArea = intersectionWidth * intersectionHeight;

  final boxAArea = boxA.width * boxA.height;
  final boxBArea = boxB.width * boxB.height;
  final unionArea = boxAArea + boxBArea - intersectionArea;

  if (unionArea <= 0) return 0.0;
  return intersectionArea / unionArea;
}
