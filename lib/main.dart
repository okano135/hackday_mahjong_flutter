// lib/main.dart
// import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers.dart';
import 'presentation/home/home_screen.dart';
// import 'utils/mahjong_api_example.dart';
// import 'data/datasources/mahjong_api_client.dart';
// import 'data/repositories/mahjong_api_repository.dart';
// import 'domain/services/mahjong_service.dart';

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  // アプリ起動時にSharedPreferencesのインスタンスを初期化し、Providerに渡す
  final prefs = await SharedPreferences.getInstance();

  // // API テスト実行
  // await _testMahjongApi();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

// /// 麻雀API テスト関数
// Future<void> _testMahjongApi() async {
//   try {
//     print('🚀 麻雀API テスト開始');

//     // プロバイダーなしで直接インスタンス作成
//     final httpClient = http.Client();
//     final apiClient = MahjongApiClient(httpClient: httpClient);
//     final repository = MahjongApiRepository(apiClient: apiClient);
//     final service = MahjongService(repository: repository);

//     final example = MahjongApiExample(service);

//     // 全ての例を実行
//     await example.runAllExamples();

//     print('✅ 麻雀API テスト完了');
//   } catch (e) {
//     print('❌ 麻雀API テストエラー: $e');
//   }
// }

// main関数の前にこのクラスを定義
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '麻雀リアルタイム支援',
      theme: ThemeData(fontFamily: "LINESeed"),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
