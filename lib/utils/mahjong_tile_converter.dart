// lib/utils/mahjong_tile_converter.dart
import '../data/models/mahjong_models.dart';
import '../data/models/mahjong_tile_model.dart';

/// 既存のPaiモデルとAPI用MahjongTileModel間の変換ユーティリティ
class MahjongTileConverter {
  /// PaiをMahjongTileModelに変換
  static MahjongTileModel paiToTileModel(Pai pai) {
    return MahjongTileModel(
      id: pai.id,
      displayName: pai.displayName,
      isDora: pai.isDora,
      isCandidate: pai.isCandidate,
    );
  }

  /// MahjongTileModelをPaiに変換
  static Pai tileModelToPai(MahjongTileModel tileModel) {
    return Pai(
      id: tileModel.id,
      displayName: tileModel.displayName,
      isDora: tileModel.isDora,
      isCandidate: tileModel.isCandidate,
    );
  }

  /// PaiリストをMahjongTileModelリストに変換
  static List<MahjongTileModel> paiListToTileModelList(List<Pai> paiList) {
    return paiList.map((pai) => paiToTileModel(pai)).toList();
  }

  /// MahjongTileModelリストをPaiリストに変換
  static List<Pai> tileModelListToPaiList(
    List<MahjongTileModel> tileModelList,
  ) {
    return tileModelList.map((tileModel) => tileModelToPai(tileModel)).toList();
  }

  /// MahjongGameStateから手牌をMahjongTileModelリストとして抽出
  static List<MahjongTileModel> extractTilesFromGameState(
    MahjongGameState gameState,
  ) {
    return gameState.hand
        .map((locatedPai) => paiToTileModel(locatedPai.pai))
        .toList();
  }

  /// 牌文字列をパースしてMahjongTileModelリストに変換
  /// 例: "112233456789m11s" -> List<MahjongTileModel>
  static List<MahjongTileModel> parseStringToTileModelList(String tilesString) {
    final List<MahjongTileModel> tiles = [];

    if (tilesString.isEmpty) {
      return tiles;
    }

    final regex = RegExp(r'([1-9]+)([mpsz])');
    final matches = regex.allMatches(tilesString);

    for (final match in matches) {
      final numbers = match.group(1)!;
      final suit = match.group(2)!;

      for (int i = 0; i < numbers.length; i++) {
        final number = numbers[i];
        final id = _buildTileId(number, suit);
        final displayName = _buildDisplayName(number, suit);

        tiles.add(MahjongTileModel(id: id, displayName: displayName));
      }
    }

    return tiles;
  }

  /// MahjongTileModelリストを牌文字列に変換
  /// 例: List<MahjongTileModel> -> "112233456789m11s"
  static String tileModelListToString(List<MahjongTileModel> tiles) {
    if (tiles.isEmpty) {
      return '';
    }

    final Map<String, List<String>> suitGroups = {
      'm': [], // 萬子
      'p': [], // 筒子
      's': [], // 索子
      'z': [], // 字牌
    };

    // 牌を種類別にグループ化
    for (final tile in tiles) {
      final suit = _extractSuitFromId(tile.id);
      final number = _extractNumberFromId(tile.id);
      if (suit != null && number != null) {
        suitGroups[suit]?.add(number);
      }
    }

    // 文字列に結合
    final StringBuffer result = StringBuffer();
    for (final entry in suitGroups.entries) {
      if (entry.value.isNotEmpty) {
        // 数字をソート
        entry.value.sort();
        result.write(entry.value.join(''));
        result.write(entry.key);
      }
    }

    return result.toString();
  }

  /// 牌ID生成 (例: "1", "m" -> "man1")
  static String _buildTileId(String number, String suit) {
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
            return 'ton'; // 東
          case '2':
            return 'nan'; // 南
          case '3':
            return 'sha'; // 西
          case '4':
            return 'pei'; // 北
          case '5':
            return 'haku'; // 白
          case '6':
            return 'hatsu'; // 發
          case '7':
            return 'chun'; // 中
          default:
            return 'z$number';
        }
      default:
        return '${suit}$number';
    }
  }

  /// 表示名生成 (例: "1", "m" -> "一萬")
  static String _buildDisplayName(String number, String suit) {
    final numberNames = ['一', '二', '三', '四', '五', '六', '七', '八', '九'];
    final numberIndex = int.parse(number) - 1;

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
        return number;
    }
  }

  /// 牌IDから種類を抽出 (例: "man1" -> "m")
  static String? _extractSuitFromId(String id) {
    if (id.startsWith('man')) return 'm';
    if (id.startsWith('pin')) return 'p';
    if (id.startsWith('sou')) return 's';
    if (['ton', 'nan', 'sha', 'pei', 'haku', 'hatsu', 'chun'].contains(id)) {
      return 'z';
    }
    return null;
  }

  /// 牌IDから数字を抽出 (例: "man1" -> "1")
  static String? _extractNumberFromId(String id) {
    if (id.startsWith('man') || id.startsWith('pin') || id.startsWith('sou')) {
      return id.substring(3);
    }
    switch (id) {
      case 'ton':
        return '1';
      case 'nan':
        return '2';
      case 'sha':
        return '3';
      case 'pei':
        return '4';
      case 'haku':
        return '5';
      case 'hatsu':
        return '6';
      case 'chun':
        return '7';
      default:
        return null;
    }
  }
}
