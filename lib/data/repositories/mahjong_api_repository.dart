// lib/data/repositories/mahjong_api_repository.dart
import '../datasources/mahjong_api_client.dart';
import '../models/recommendation_response_model.dart';
import '../models/score_calculation_response_model.dart';

/// 麻雀APIリポジトリ
class MahjongApiRepository {
  final MahjongApiClient _apiClient;

  MahjongApiRepository({required MahjongApiClient apiClient})
    : _apiClient = apiClient;

  /// 推奨牌を取得 (牌文字列で) - 例: "112233456788m112s"
  Future<RecommendationResponseModel> getRecommendationFromString({
    required String tilesString,
  }) async {
    try {
      return await _apiClient.getRecommendationFromString(
        tilesString: tilesString,
      );
    } catch (e) {
      // エラーログまたは変換ロジック追加可能
      rethrow;
    }
  }

  /// 点数計算 (牌文字列で) - 例: "112233456789m11s"
  Future<ScoreCalculationResponseModel> calculateScoreFromString({
    required String tilesString,
    String? extra,
    List<String>? dora,
    String? wind,
  }) async {
    try {
      return await _apiClient.calculateScoreFromString(
        tilesString: tilesString,
        extra: extra,
        dora: dora,
        wind: wind,
      );
    } catch (e) {
      // エラーログまたは変換ロジック追加可能
      rethrow;
    }
  }

  /// リソース清理
  void dispose() {
    _apiClient.dispose();
  }
}
