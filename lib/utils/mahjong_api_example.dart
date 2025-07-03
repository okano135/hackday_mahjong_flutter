// lib/utils/mahjong_api_example.dart
import '../domain/services/mahjong_service.dart';
import '../data/models/mahjong_tile_model.dart';

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
      // 例: "112233456789m11s" (14枚 - 完成状態)
      const tilesString = "112233456789m11s";

      final response = await _mahjongService.calculateScoreFromString(
        tilesString: tilesString,
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
    } catch (e) {
      print('点数計算失敗: $e');
    }
  }

  /// リスト形式でAPI呼び出し例
  Future<void> getRecommendationWithTileListExample() async {
    try {
      // MahjongTileModelリストに変換
      final tiles = [
        const MahjongTileModel(id: 'man1', displayName: '一萬'),
        const MahjongTileModel(id: 'man1', displayName: '一萬'),
        const MahjongTileModel(id: 'man2', displayName: '二萬'),
        const MahjongTileModel(id: 'man2', displayName: '二萬'),
        const MahjongTileModel(id: 'man3', displayName: '三萬'),
        const MahjongTileModel(id: 'man3', displayName: '三萬'),
        const MahjongTileModel(id: 'man4', displayName: '四萬'),
        const MahjongTileModel(id: 'man5', displayName: '五萬'),
        const MahjongTileModel(id: 'man6', displayName: '六萬'),
        const MahjongTileModel(id: 'man7', displayName: '七萬'),
        const MahjongTileModel(id: 'man8', displayName: '八萬'),
        const MahjongTileModel(id: 'man8', displayName: '八萬'),
        const MahjongTileModel(id: 'sou1', displayName: '一索'),
      ];

      final response = await _mahjongService.getRecommendation(tiles: tiles);

      print('リスト形式推奨牌結果:');
      print('推奨牌: ${response.recommend}');
      print('推奨牌表示名: ${response.recommendedTileDisplayName}');
    } catch (e) {
      print('リスト形式推奨牌取得失敗: $e');
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

    print('3. リスト形式で推奨牌取得:');
    await getRecommendationWithTileListExample();
    print('\n');

    print('=== 例完了 ===');
  }
}
