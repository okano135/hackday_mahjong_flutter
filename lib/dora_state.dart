import 'package:flutter_riverpod/flutter_riverpod.dart';

// ドラを管理する Notifier
class DoraStateNotifier extends StateNotifier<List<String>> {
  // 初期状態として空のリストを持たせる
  DoraStateNotifier() : super([]);

  // ドラの牌を追加するメソッド
  void addDora(String dora) {
    // 既存のドラがある場合も追加
    if (!state.contains(dora)) {
      state = [...state, dora];
    }
  }

  // ドラの牌をクリアするメソッド
  void clearDora() {
    state = [];
  }

  // ドラを削除するメソッド
  void removeDora(String dora) {
    // ドラが存在する場合のみ削除
    if (state.contains(dora)) {
      state = state.where((item) => item != dora).toList();
    }
  }
}

// StateNotifierProviderを定義
final doraProvider = StateNotifierProvider<DoraStateNotifier, List<String>>(
  (ref) => DoraStateNotifier(),
);
