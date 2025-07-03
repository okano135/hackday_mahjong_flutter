// lib/data/models/mahjong_tile_model.dart
/// API通信用の麻雀牌モデル
class MahjongTileModel {
  /// 牌の種類ID (例: "man1", "hatsu")
  final String id;

  /// 牌の表示名 (例: "一萬", "發")
  final String displayName;

  /// ドラかどうか
  final bool isDora;

  /// 打牌候補かどうか
  final bool isCandidate;

  const MahjongTileModel({
    required this.id,
    required this.displayName,
    this.isDora = false,
    this.isCandidate = false,
  });

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'isDora': isDora,
      'isCandidate': isCandidate,
    };
  }

  /// JSONから生成
  factory MahjongTileModel.fromJson(Map<String, dynamic> json) {
    return MahjongTileModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      isDora: json['isDora'] as bool? ?? false,
      isCandidate: json['isCandidate'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MahjongTileModel &&
        other.id == id &&
        other.displayName == displayName &&
        other.isDora == isDora &&
        other.isCandidate == isCandidate;
  }

  @override
  int get hashCode {
    return Object.hash(id, displayName, isDora, isCandidate);
  }

  @override
  String toString() {
    return 'MahjongTileModel(id: $id, displayName: $displayName, isDora: $isDora, isCandidate: $isCandidate)';
  }
}
