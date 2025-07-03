// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultralytics_yolo/yolo_streaming_config.dart';
import 'package:ultralytics_yolo/yolo_task.dart';
import 'package:ultralytics_yolo/yolo_view.dart';

import 'core/providers.dart';
import 'core/theme.dart';
import 'hand_state.dart'; // 作成した hand_state.dart をインポート

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: AdvancedCameraScreen(),
    );
  }
}

// StatelessWidget から ConsumerWidget に変更
class AdvancedCameraScreen extends ConsumerWidget {
  @override
  // build メソッドに WidgetRef ref を追加
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          YOLOView(
            modelPath: 'best_re 3',
            task: YOLOTask.detect,
            streamingConfig: YOLOStreamingConfig.throttled(
              maxFPS: 15,
              includeMasks: false,
              includeOriginalImage: false,
            ),
            onStreamingData: (data) {
              final detections = data['detections'] as List? ?? [];
              // Notifier を通じて手牌の状態を更新
              ref.read(handProvider.notifier).updateHand(detections);
            },
          ),
        ],
      ),
    );
  }
}
