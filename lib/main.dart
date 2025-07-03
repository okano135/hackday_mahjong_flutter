// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'core/providers.dart';
import 'core/theme.dart';
import 'presentation/camera/camera_screen.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/camera/advanced_camera_screen.dart'; // 変更: インポートパスを修正

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // アプリ起動時にSharedPreferencesのインスタンスを初期化し、Providerに渡す
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
