// lib/core/providers.dart
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../data/repositories/inference_repository.dart';
import '../data/strategies/api_inference_strategy.dart';
import '../data/strategies/inference_strategy.dart';
import '../data/strategies/local_inference_strategy.dart';
import '../data/datasources/mahjong_api_client.dart';
import '../data/repositories/mahjong_api_repository.dart';
import '../domain/services/mahjong_service.dart';

// --- Core Providers ----------------------------------------------------------

/// 利用可能なカメラのリストを提供するProvider
final availableCamerasProvider = FutureProvider<List<CameraDescription>>((ref) {
  return availableCameras();
});

/// SharedPreferencesのインスタンスを提供するProvider
/// main.dartで初期化時に値が上書きされる
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Provider was not initialized');
});

// --- Mahjong API Providers ---------------------------------------------------

/// HTTPクライアントプロバイダー
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

/// 麻雀APIクライアントプロバイダー
final mahjongApiClientProvider = Provider<MahjongApiClient>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  return MahjongApiClient(httpClient: httpClient);
});

/// 麻雀APIリポジトリプロバイダー
final mahjongApiRepositoryProvider = Provider<MahjongApiRepository>((ref) {
  final apiClient = ref.watch(mahjongApiClientProvider);
  return MahjongApiRepository(apiClient: apiClient);
});

/// 麻雀サービスプロバイダー
final mahjongServiceProvider = Provider<MahjongService>((ref) {
  final repository = ref.watch(mahjongApiRepositoryProvider);
  return MahjongService(repository: repository);
});

// --- Settings Providers ------------------------------------------------------

/// 推論モード（'local' or 'api'）を管理するStateProvider
final inferenceModeProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  // 保存された値があればそれを使い、なければ'local'をデフォルトにする
  return prefs.getString('inference_mode') ?? 'local';
});

// --- Repository / Strategy Providers -----------------------------------------

/// 現在の推論モードに応じて適切なStrategyインスタンスを提供するProvider
/// inferenceModeProviderを監視し、モードが変更されると自動的に再生成される
final inferenceStrategyProvider = Provider<InferenceStrategy>((ref) {
  final mode = ref.watch(inferenceModeProvider);

  // モードに応じて適切なStrategyを返す
  final strategy = switch (mode) {
    'api' => ApiInferenceStrategy(),
    _ => LocalInferenceStrategy(), // デフォルトはlocal
  };

  // Providerが破棄されるタイミングで、strategyのdisposeメソッドを呼び出す
  ref.onDispose(() => strategy.dispose());

  return strategy;
});

/// 推論処理を行うリポジトリを提供するProvider
/// inferenceStrategyProviderから現在のStrategyを受け取り、リポジトリを生成する
final inferenceRepositoryProvider = Provider<InferenceRepository>((ref) {
  final strategy = ref.watch(inferenceStrategyProvider);
  return InferenceRepository(strategy);
});
