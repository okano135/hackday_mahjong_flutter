// lib/data/models/mahjong_models.dart
import 'dart:ui';

// --- 麻雀関連のモデルをこのファイルに統合 ---

/// 麻雀牌を表現するクラス
class Pai {
  /// 牌の種類を示す内部的なID (例: "man1", "hatsu")
  final String id;

  /// 表示用の名前 (例: "一萬", "發")
  final String displayName;

  /// ドラかどうか
  bool isDora;

  /// 打牌候補かどうか
  bool isCandidate;

  Pai({
    required this.id,
    required this.displayName,
    this.isDora = false,
    this.isCandidate = false,
  });
}

/// 牌の位置情報を追加したクラス
class LocatedPai {
  final Pai pai;
  final Rect position;

  LocatedPai({required this.pai, required this.position});
}

/// 現在の麻雀のゲーム状態を表現するクラス
class MahjongGameState {
  /// 認識された手牌のリスト
  final List<LocatedPai> hand;

  /// 認識されたドラ表示牌
  final LocatedPai? doraIndicator;

  /// 計算されたドラのリスト
  final List<Pai> dora;

  MahjongGameState({
    required this.hand,
    this.doraIndicator,
    required this.dora,
  });

  /// 空のゲーム状態を生成するファクトリコンストラクタ
  factory MahjongGameState.empty() {
    return MahjongGameState(hand: [], dora: []);
  }
}
