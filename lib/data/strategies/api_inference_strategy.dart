// lib/data/strategies/api_inference_strategy.dart
import 'dart:convert';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import '../models/detection_result.dart';
import 'inference_strategy.dart';

/// APIサーバー経由で推論を行う戦略
class ApiInferenceStrategy implements InferenceStrategy {
  // TODO: 自身のAPIサーバーのURLに書き換えてください
  final Uri apiUrl = Uri.parse("https://35.243.124.69:8000/process_frame");

  @override
  Future<List<DetectionResult>> runInference(CameraImage image) async {
    try {
      // 1. CameraImageをJPEGに変換する
      // この変換処理は重い場合がある
      final jpegImage = _convertYUV420toImage(image);
      final jpegBytes = img.encodeJpg(jpegImage);

      // 2. マルチパートリクエストを作成
      final request = http.MultipartRequest('POST', apiUrl)
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            jpegBytes,
            filename: 'image.jpg',
          ),
        );

      // 3. APIにリクエストを送信
      final response = await request.send();

      if (response.statusCode == 200) {
        // 4. 成功した場合、レスポンス(JSON)をパースして結果を返す
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        final List<dynamic> detections = jsonResponse['detections'];

        return detections.map((d) {
          final List<dynamic> box = d['box'];
          return DetectionResult(
            label: d['label'],
            confidence: d['confidence'].toDouble(),
            boundingBox: Rect.fromLTWH(
              box[0].toDouble(),
              box[1].toDouble(),
              box[2].toDouble(),
              box[3].toDouble(),
            ),
          );
        }).toList();
      } else {
        // エラーハンドリング
        print('API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error in ApiInferenceStrategy: $e');
      return [];
    }
  }

  /// CameraImage (YUV420フォーマット) を imageライブラリのImageオブジェクトに変換する
  /// このコードはimageパッケージのサンプルを参考にしています
  img.Image _convertYUV420toImage(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel!;

    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final convertedImage = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIndex = y * width + x;
        final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

        final yValue = yPlane[yIndex];
        final uValue = uPlane[uvIndex];
        final vValue = vPlane[uvIndex];

        // YUV to RGB変換
        final r = yValue + 1.402 * (vValue - 128);
        final g =
            yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128);
        final b = yValue + 1.772 * (uValue - 128);

        convertedImage.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt(), 255);
      }
    }
    return convertedImage;
  }

  @override
  void dispose() {
    // API戦略では解放するリソースは特にない
  }
}
