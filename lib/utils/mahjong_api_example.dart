// lib/utils/mahjong_api_example.dart
import '../domain/services/mahjong_service.dart';

/// 麻雀API使用例を示すユーティリティクラス
class MahjongApiExample {
  final MahjongService _mahjongService;

  MahjongApiExample(this._mahjongService);

  /// 文字列形式で推奨牌取得例
  Future<void> getRecommendationExample() async {
    try {
      // 例: "11223345678m112s" (萬子牌 + 索子牌)
      const tilesString = "11223345678m112s";

      final response = await _mahjongService.getRecommendationFromString(
        tilesString: tilesString,
      );

      print('推奨牌結果:');
      print('推奨牌: ${response.recommend}');
      print('推奨牌ID: ${response.recommendedTileId}');
      print('推奨牌表示名: ${response.recommendedTileDisplayName}');
    } catch (e) {
      print('推奨牌取得失敗: $e');
    }
  }

  /// 文字列形式で点数計算例
  Future<void> calculateScoreExample() async {
    try {
      // 例: "23m456678p345s33z1m" (複雑なオプション付き)
      const tilesString = "23m456678p345s33z1m";

      final response = await _mahjongService.calculateScoreFromString(
        tilesString: tilesString,
        extra: "r", // リーチ
        dora: ["2m", "7s"], // ドラ牌
        wind: "14", // 風情報
      );

      print('点数計算結果:');
      print('成功: ${response.success}');
      print('エラー: ${response.error ?? "なし"}');

      // 結果情報
      final result = response.result;
      print('結果情報:');
      print('  完成かどうか: ${result.isAgari}');
      print('  役満: ${result.yakuman}');
      print('  総翻数: ${result.han}');
      print('  符数: ${result.fu}');
      print('  点数: ${result.ten}');
      print('  説明: ${result.text}');

      // 役情報
      if (result.yaku.isNotEmpty) {
        print('完成した役:');
        result.yaku.forEach((yakuName, hanString) {
          print('  $yakuName: $hanString');
        });
      } else {
        print('完成した役がありません。');
      }

      // 点数配分
      if (result.oya.isNotEmpty) {
        print('親の点数配分: ${result.oya}');
      }
      if (result.ko.isNotEmpty) {
        print('子の点数配分: ${result.ko}');
      }

      // 入力情報
      print('入力情報:');
      print('  元の牌: ${response.input.originalHand}');
      print('  処理された牌: ${response.input.processedHand}');
      print('  ドラ: ${response.input.options.dora}');
      print('  風: ${response.input.options.wind ?? "なし"}');
    } catch (e) {
      print('点数計算失敗: $e');
    }
  }

  /// 全ての例を実行
  Future<void> runAllExamples() async {
    print('=== 麻雀API使用例 ===\n');

    print('1. 文字列形式で推奨牌取得:');
    await getRecommendationExample();
    print('\n');

    print('2. 文字列形式で点数計算:');
    await calculateScoreExample();
    print('\n');

    print('=== 例完了 ===');
  }
}
