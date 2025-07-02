// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

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
    return YOLOView(
      modelPath: 'best_re',
      task: YOLOTask.detect,
      onResult: (results) {
        print('Found ${results.length} objects!');
        for (final result in results) {
          print('${result.className}: ${result.confidence}');
        }
      },
    );
  }
}
