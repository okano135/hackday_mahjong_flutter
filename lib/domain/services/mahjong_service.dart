// lib/domain/services/mahjong_service.dart
import '../../data/models/mahjong_tile_model.dart';
import '../../data/models/recommendation_response_model.dart';
import '../../data/models/score_calculation_response_model.dart';
import '../../data/repositories/mahjong_api_repository.dart';

/// 麻雀ビジネスロジックサービス
class MahjongService {
  final MahjongApiRepository _repository;

  MahjongService({required MahjongApiRepository repository})
    : _repository = repository;

  /// 推奨牌を取得
  Future<RecommendationResponseModel> getRecommendation({
    required List<MahjongTileModel> tiles,
  }) async {
    // ビジネスロジック追加可能 (例: バリデーション、キャッシュなど)
    if (tiles.isEmpty) {
      throw ArgumentError('牌リストが空です。');
    }

    return await _repository.getRecommendation(tiles: tiles);
  }

  /// 点数計算
  Future<ScoreCalculationResponseModel> calculateScore({
    required List<MahjongTileModel> tiles,
  }) async {
    // ビジネスロジック追加可能 (例: バリデーション、キャッシュなど)
    if (tiles.isEmpty) {
      throw ArgumentError('牌リストが空です。');
    }

    // 一般的に13枚または14枚である必要がある
    if (tiles.length < 13 || tiles.length > 14) {
      throw ArgumentError('牌数が正しくありません。 (${tiles.length}枚)');
    }

    return await _repository.calculateScore(tiles: tiles);
  }

  /// 推奨牌を取得 (牌文字列で) - 例: "112233456788m112s"
  Future<RecommendationResponseModel> getRecommendationFromString({
    required String tilesString,
  }) async {
    // ビジネスロジック追加可能 (例: バリデーション、キャッシュなど)
    if (tilesString.isEmpty) {
      throw ArgumentError('牌文字列が空です。');
    }

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
    required String tilesString,
  }) async {
    // ビジネスロジック追加可能 (例: バリデーション、キャッシュなど)
    if (tilesString.isEmpty) {
      throw ArgumentError('牌文字列が空です。');
    }

    // 簡単なバリデーション (麻雀牌文字列形式)
    if (!_isValidTilesString(tilesString)) {
      throw ArgumentError('正しくない牌文字列形式です: $tilesString');
    }

    return await _repository.calculateScoreFromString(tilesString: tilesString);
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
