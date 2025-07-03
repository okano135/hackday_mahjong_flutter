// lib/utils/mahjong_api_example.dart
import '../domain/services/mahjong_service.dart';
import 'mahjong_tile_converter.dart';

/// 麻雀API使用例を示すユーティリティクラス
class MahjongApiExample {
  final MahjongService _mahjongService;

  MahjongApiExample(this._mahjongService);

  /// 推奨牌テスト用データ生成 (結果: "11223345678m112s")
  static List<dynamic> createRecommendTestData() {
    return [
      // Manzu1 x2
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 7,
        "className": "Manzu1",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 7,
        "className": "Manzu1",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu2 x2
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 8,
        "className": "Manzu2",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 8,
        "className": "Manzu2",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu3 x2
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 9,
        "className": "Manzu3",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 9,
        "className": "Manzu3",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu4 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 10,
        "className": "Manzu4",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu5 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 11,
        "className": "Manzu5",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu6 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 12,
        "className": "Manzu6",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu7 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 13,
        "className": "Manzu7",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu8 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 14,
        "className": "Manzu8",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Souzu1 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 18,
        "className": "Souzu1",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Souzu1 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 18,
        "className": "Souzu1",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Souzu2 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 19,
        "className": "Souzu2",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
    ];
  }

  /// 点数計算テスト用データ生成 (結果: "23m456678p345s33z1m")
  static List<dynamic> createScoreTestData() {
    return [
      // Manzu2 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 8,
        "className": "Manzu2",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu3 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 9,
        "className": "Manzu3",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Pinzu4 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 3,
        "className": "Pinzu4",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Pinzu5 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 4,
        "className": "Pinzu5",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Pinzu6 x2
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 5,
        "className": "Pinzu6",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 5,
        "className": "Pinzu6",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Pinzu7 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 6,
        "className": "Pinzu7",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Pinzu8 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 7,
        "className": "Pinzu8",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Souzu3 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 20,
        "className": "Souzu3",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Souzu4 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 21,
        "className": "Souzu4",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Souzu5 x1
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 22,
        "className": "Souzu5",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Chun (中) x2 -> z牌의 7
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 33,
        "className": "Chun",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 33,
        "className": "Chun",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
      // Manzu1 x1 (最後に追加)
      {
        "normalizedBox": {
          "bottom": 0.634857177734375,
          "top": 0.559478759765625,
          "right": 0.7342529296875,
          "left": 0.6007080078125,
        },
        "classIndex": 7,
        "className": "Manzu1",
        "confidence": 0.9987589716911316,
        "boundingBox": {
          "bottom": 990.377197265625,
          "right": 859.075927734375,
          "top": 872.786865234375,
          "left": 702.828369140625,
        },
      },
    ];
  }

  /// 変換テスト実行
  void testTileConverter() {
    print('=== MahjongTileConverter テスト ===\n');

    // 推奨牌テスト
    final recommendData = createRecommendTestData();
    final recommendResult =
        MahjongTileConverter.convertDetectedTilesToApiString(recommendData);
    print('推奨牌テストデータ変換結果:');
    print('期待値: 11223345678m112s');
    print('実際値: $recommendResult');
    print('一致: ${recommendResult == "11223345678m112s" ? "✓" : "✗"}\n');

    // 点数計算テスト
    final scoreData = createScoreTestData();
    final scoreResult = MahjongTileConverter.convertDetectedTilesToApiString(
      scoreData,
    );
    print('点数計算テストデータ変換結果:');
    print('期待値: 23m456678p345s33z1m');
    print('実際値: $scoreResult');
    print('一致: ${scoreResult == "23m456678p345s33z1m" ? "✓" : "✗"}\n');
  }

  /// 文字列形式で推奨牌取得例
  Future<void> getRecommendationExample() async {
    try {
      // 例: "11223345678m112s" (萬子牌 + 索子牌)

      final response = await _mahjongService.getRecommendationFromString(
        tiles: createRecommendTestData(),
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
      // 例: "23m456678p345s33z1m"

      final response = await _mahjongService.calculateScoreFromString(
        tiles: createScoreTestData(),
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
