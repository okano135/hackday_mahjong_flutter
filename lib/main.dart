// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultralytics_yolo/yolo_streaming_config.dart';
import 'package:ultralytics_yolo/yolo_task.dart';
import 'package:ultralytics_yolo/yolo_view.dart';
import 'dart:typed_data';

import 'core/providers.dart';
import 'core/theme.dart';
import 'presentation/camera/camera_screen.dart';

Future<void> main() async {
  // main関数で非同期処理を呼び出すためのおまじない
  WidgetsFlutterBinding.ensureInitialized();

  // アプリ起動時にSharedPreferencesのインスタンスを初期化し、Providerに渡す
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // sharedPreferencesProviderの値を上書き
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '麻雀リアルタイム支援',
      theme: AppTheme.lightTheme, // アプリのテーマを適用
      debugShowCheckedModeBanner: false,
      home: AdvancedCameraScreen(), // 最初の画面としてカメラ画面を指定
    );

  }
}


class AdvancedCameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YOLOView(
        modelPath: 'best_re',
        task: YOLOTask.detect,

        // Configure streaming behavior
        streamingConfig: YOLOStreamingConfig.throttled(
          maxFPS: 15, // Limit to 15 FPS for battery saving
          includeMasks: false, // Disable masks for performance
          includeOriginalImage: false, // Save bandwidth
        ),

        // Comprehensive callback
        onStreamingData: (data) {
          final detections = data['detections'] as List? ?? [];
          final fps = data['fps'] as double? ?? 0.0;
          final originalImage = data['originalImage'] as Uint8List?;

          print('Streaming: ${detections.length} detections at ${fps.toStringAsFixed(1)} FPS');

          // Process complete frame data
          processFrameData(detections, originalImage);
        },
      ),
    );
  }

  void processFrameData(List detections, Uint8List? imageData) {
    // Custom processing logic
    for (final detection in detections) {
      final className = detection['className'] as String?;
      final confidence = detection['confidence'] as double?;

      if (confidence != null && confidence > 0.8) {
        print('High confidence detection: $className (${(confidence * 100).toStringAsFixed(1)}%)');
      }
    }
  }
}