// lib/domain/services/mahjong_service.dart
import '../../data/models/recommendation_response_model.dart';
import '../../data/models/score_calculation_response_model.dart';
import '../../data/models/tenpai_response_model.dart';
import '../../data/repositories/mahjong_api_repository.dart';
import '../../utils/mahjong_tile_converter.dart';

/// 麻雀ビジネスロジックサービス
class MahjongService {
  final MahjongApiRepository _repository;

  MahjongService({required MahjongApiRepository repository})
    : _repository = repository;

  /// 推奨牌を取得 (牌文字列で) - 例: "112233456788m112s"
  Future<RecommendationResponseModel> getRecommendationFromString({
    required List<dynamic> tiles,
  }) async {
    // ビジネスロジック追加可能 (例: バリデーション、キャッシュなど)

    if (tiles.isEmpty) {
      throw ArgumentError('牌文字列が空です。');
    }
    // 牌リストを文字列形式に変換
    final tilesString = MahjongTileConverter.convertDetectedTilesToApiString(
      tiles,
    );

    // 簡単なバリデーション (麻雀牌文字列形式)
    if (!_isValidTilesString(tilesString)) {
      throw ArgumentError('正しくない牌文字列形式です: $tilesString');
    }

    return await _repository.getRecommendationFromString(
      tilesString: tilesString,
    );
  }

  /// 点数計算 (牌文字列で) - 例: "112233456789m11s"
  Future<ScoreCalculationResponseModel> calculateScoreFromString({
    required List<dynamic> tiles,
    String? extra,
    List<String>? dora,
    String? wind,
  }) async {
    // ビジネスロジック追加可能 (例: バリデーション、キャッシュなど)

    if (tiles.isEmpty) {
      throw ArgumentError('牌文字列が空です。');
    }
    // 牌リストを文字列形式に変換
    final tilesString = MahjongTileConverter.convertDetectedTilesToApiString(
      tiles,
    );

    // 簡単なバリデーション (麻雀牌文字列形式)
    if (!_isValidTilesString(tilesString)) {
      throw ArgumentError('正しくない牌文字列形式です: $tilesString');
    }

    return await _repository.calculateScoreFromString(
      tilesString: tilesString,
      extra: extra,
      dora: dora,
      wind: wind,
    );
  }

  /// 和了り牌 チェック (牌検出結果で) - 例: "23456m456p345s33z"
  Future<TenpaiResponseModel> checkTenpaiFromDetectedTiles({
    required List<dynamic> tiles,
  }) async {
    // ビジネスロジック追加可能 (例: バリデーション、キャッシュなど)

    if (tiles.isEmpty) {
      throw ArgumentError('牌文字列が空です。');
    }
    // 牌リストを文字列形式に変換
    final tilesString = MahjongTileConverter.convertDetectedTilesToApiString(
      tiles,
    );

    // 簡単なバリデーション (麻雀牌文字列形式)
    if (!_isValidTilesString(tilesString)) {
      throw ArgumentError('正しくない牌文字列形式です: $tilesString');
    }

    return await _repository.checkTenpaiFromString(tilesString: tilesString);
  }

  /// 牌文字列形式が有効かチェックするヘルパーメソッド
  bool _isValidTilesString(String tilesString) {
    // 基本的な麻雀牌文字列形式チェック
    // 例: "112233456789m11s" - 数字 + 種類(m/p/s/z)
    final regex = RegExp(r'^[1-9]+[mpsz]?(?:[1-9]+[mpsz]?)*$');
    return regex.hasMatch(tilesString);
  }

  /// リソース清理
  void dispose() {
    _repository.dispose();
  }
}
