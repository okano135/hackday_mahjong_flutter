import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 手牌の状態（検出された牌のクラス名のリスト）を管理する Notifier
class HandStateNotifier extends StateNotifier<List<String>> {
  // 初期状態として空のリストを持たせる
  HandStateNotifier() : super([]);

  // --- 状態を安定させるための追加プロパティ ---

  /// 更新候補の牌リスト
  List<String> _candidateHand = [];

  /// 候補が連続で検出されたフレーム数
  int _consecutiveFrames = 0;

  /// 状態を更新するために必要な連続検出フレーム数
  /// この値を大きくするとより安定しますが、反応は少し遅くなります。
  static const int _requiredStableFrames = 3;

  /// 検出の信頼度のしきい値
  static const double _confidenceThreshold = 0.7;

  // 検出結果に基づいて手牌の状態を更新するメソッド
  void updateHand(List<dynamic> detections) {
    // 1. 今回のフレームで検出された牌をリスト化・ソートする
    final newHand = detections
        .where(
          (d) => (d['confidence'] as double? ?? 0.0) > _confidenceThreshold,
        )
        .map((d) => d['className'] as String? ?? '')
        .toList();
    newHand.sort();

    // 2. 更新候補のリストと比較する
    if (listEquals(newHand, _candidateHand)) {
      // 前回と同じ内容なら、連続カウンターを増やす
      _consecutiveFrames++;
    } else {
      // 違う内容なら、新しい内容を候補にしてカウンターをリセット
      _candidateHand = newHand;
      _consecutiveFrames = 1;
    }

    // 3. 連続検出カウンターが指定回数に達したかチェック
    if (_consecutiveFrames >= _requiredStableFrames) {
      // 4. 達した場合、現在の公開状態（state）と候補（_candidateHand）が違う場合のみ更新する
      //    これにより、不要なUIの再描画を防ぐ
      if (!listEquals(state, _candidateHand)) {
        state = _candidateHand;
      }
    }
  }
}

// StateNotifierProvider (変更なし)
final handProvider =
    StateNotifierProvider.autoDispose<HandStateNotifier, List<String>>(
      (ref) => HandStateNotifier(),
    );
