// lib/data/datasources/mahjong_api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/mahjong_tile_model.dart';
import '../models/recommendation_response_model.dart';
import '../models/score_calculation_response_model.dart';

/// 麻雀APIクライアント
class MahjongApiClient {
  static const String _baseUrl = 'https://test-api.com';

  final http.Client _httpClient;

  MahjongApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// 推奨牌API呼び出し (牌リストで)
  Future<RecommendationResponseModel> getRecommendation({
    required List<MahjongTileModel> tiles,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/recommendation');

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'tiles': tiles.map((tile) => tile.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecommendationResponseModel.fromJson(data);
      } else {
        throw MahjongApiException(
          'Failed to get recommendation: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is MahjongApiException) rethrow;
      throw MahjongApiException('Network error: $e');
    }
  }

  /// 推奨牌API呼び出し (牌文字列で) - 例: "112233456788m112s"
  Future<RecommendationResponseModel> getRecommendationFromString({
    required String tilesString,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/recommendation');

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'hand': tilesString}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return RecommendationResponseModel.fromJson(data);
      } else {
        throw MahjongApiException(
          'Failed to get recommendation: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is MahjongApiException) rethrow;
      throw MahjongApiException('Network error: $e');
    }
  }

  /// 点数計算API呼び出し (牌リストで)
  Future<ScoreCalculationResponseModel> calculateScore({
    required List<MahjongTileModel> tiles,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/score-calculation');

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'tiles': tiles.map((tile) => tile.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ScoreCalculationResponseModel.fromJson(data);
      } else {
        throw MahjongApiException(
          'Failed to calculate score: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is MahjongApiException) rethrow;
      throw MahjongApiException('Network error: $e');
    }
  }

  /// 点数計算API呼び出し (牌文字列で) - 例: "112233456789m11s"
  Future<ScoreCalculationResponseModel> calculateScoreFromString({
    required String tilesString,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/score-calculation');

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'hand': tilesString}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ScoreCalculationResponseModel.fromJson(data);
      } else {
        throw MahjongApiException(
          'Failed to calculate score: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is MahjongApiException) rethrow;
      throw MahjongApiException('Network error: $e');
    }
  }

  /// リソース清理
  void dispose() {
    _httpClient.close();
  }
}

/// 麻雀API例外クラス
class MahjongApiException implements Exception {
  final String message;
  final int? statusCode;

  const MahjongApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'MahjongApiException: $message';
}
