import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 手牌の状態（検出された牌のクラス名のリスト）を管理する Notifier
class HandStateNotifier extends StateNotifier<List<String>> {
  // 初期状態として空のリストを持たせる
  HandStateNotifier() : super([]);

  // 検出結果に基づいて手牌の状態を更新するメソッド
  void updateHand(List<dynamic> detections) {
    // 信頼度が一定以上（例: 70%）の牌だけを抽出
    final confidentDetections = detections
        .where((d) => (d['confidence'] as double? ?? 0.0) > 0.7)
        .map((d) => d['className'] as String? ?? '')
        .toList();

    // 表示を安定させるためにソートする
    confidentDetections.sort();

    // 現在の状態と新しい状態が異なる場合のみ更新（不要な再描画を防ぐ）
    if (!listEquals(state, confidentDetections)) {
      state = confidentDetections;
    }
  }
}

// StateNotifierProvider を定義
// autoDispose をつけて、ウィジェットが破棄されたときに Provider も自動で破棄されるようにする
final handProvider =
    StateNotifierProvider.autoDispose<HandStateNotifier, List<String>>(
      (ref) => HandStateNotifier(),
    );
