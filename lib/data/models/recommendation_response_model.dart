// lib/data/models/recommendation_response_model.dart

/// 推奨牌API応答モデル (簡単な形式)
class RecommendationResponseModel {
  /// 推奨する牌 (例: "2s")
  final String recommend;

  const RecommendationResponseModel({required this.recommend});

  /// JSONから生成
  factory RecommendationResponseModel.fromJson(Map<String, dynamic> json) {
    return RecommendationResponseModel(recommend: json['recommend'] as String);
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {'recommend': recommend};
  }

  /// 推奨牌をタイルIDに変換 (例: "2s" -> "sou2")
  String get recommendedTileId {
    if (recommend.isEmpty || recommend.length < 2) {
      return recommend;
    }

    final number = recommend.substring(0, recommend.length - 1);
    final suit = recommend.substring(recommend.length - 1);

    switch (suit) {
      case 'm':
        return 'man$number';
      case 'p':
        return 'pin$number';
      case 's':
        return 'sou$number';
      case 'z':
        switch (number) {
          case '1':
            return 'ton';
          case '2':
            return 'nan';
          case '3':
            return 'sha';
          case '4':
            return 'pei';
          case '5':
            return 'haku';
          case '6':
            return 'hatsu';
          case '7':
            return 'chun';
          default:
            return 'z$number';
        }
      default:
        return recommend;
    }
  }

  /// 推奨牌の表示名を取得 (例: "2s" -> "二索")
  String get recommendedTileDisplayName {
    if (recommend.isEmpty || recommend.length < 2) {
      return recommend;
    }

    final number = recommend.substring(0, recommend.length - 1);
    final suit = recommend.substring(recommend.length - 1);

    try {
      final numberIndex = int.parse(number) - 1;
      final numberNames = ['一', '二', '三', '四', '五', '六', '七', '八', '九'];

      switch (suit) {
        case 'm':
          return '${numberNames[numberIndex]}萬';
        case 'p':
          return '${numberNames[numberIndex]}筒';
        case 's':
          return '${numberNames[numberIndex]}索';
        case 'z':
          switch (number) {
            case '1':
              return '東';
            case '2':
              return '南';
            case '3':
              return '西';
            case '4':
              return '北';
            case '5':
              return '白';
            case '6':
              return '發';
            case '7':
              return '中';
            default:
              return number;
          }
        default:
          return recommend;
      }
    } catch (e) {
      return recommend;
    }
  }

  @override
  String toString() {
    return 'RecommendationResponseModel(recommend: $recommend)';
  }
}
