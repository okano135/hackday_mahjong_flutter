// lib/utils/mahjong_tile_converter.dart

/// 検出された牌情報をAPI用文字列に変換するユーティリティ
class MahjongTileConverter {
  /// 検出された牌情報から className を抽出して API 用文字列に変換
  /// 例: [{"className": "Manzu5"}, {"className": "Manzu6"}] -> "56m"
  static String convertDetectedTilesToApiString(List<dynamic> detectedTiles) {
    if (detectedTiles.isEmpty) {
      return '';
    }

    // className を抽出
    final List<String> classNames = detectedTiles
        .map((tile) => tile['className'] as String?)
        .where((className) => className != null)
        .cast<String>()
        .toList();

    return convertClassNamesToApiString(classNames);
  }

  /// className リストを API 用文字列に変換
  /// 例: ["Manzu5", "Manzu6", "Pinzu1", "Pinzu2"] -> "56m12p"
  static String convertClassNamesToApiString(List<String> classNames) {
    if (classNames.isEmpty) {
      return '';
    }

    // 最後の牌を除外して処理
    final String? lastTile = classNames.isNotEmpty ? classNames.last : null;
    final List<String> timesExceptLast = classNames.length > 1
        ? classNames.sublist(0, classNames.length - 1)
        : [];

    final Map<String, List<String>> suitGroups = {
      'm': [], // 萬子 (Manzu)
      'p': [], // 筒子 (Pinzu)
      's': [], // 索子 (Souzu)
      'z': [], // 字牌 (Jihai)
    };

    // className をパースして種類別にグループ化
    for (final className in timesExceptLast) {
      final parsedTile = _parseClassName(className);
      if (parsedTile != null) {
        suitGroups[parsedTile['suit']]?.add(parsedTile['number']!);
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

    // 最後の牌を特別に処理
    if (lastTile != null) {
      final parsedLastTile = _parseClassName(lastTile);
      if (parsedLastTile != null) {
        result.write(parsedLastTile['number']);
        result.write(parsedLastTile['suit']);
      }
    }

    return result.toString();
  }

  /// className をパースして種類と数字を抽出
  /// 例: "Manzu5" -> {"suit": "m", "number": "5"}
  static Map<String, String>? _parseClassName(String className) {
    // 萬子 (Manzu1~9)
    if (className.startsWith('Manzu')) {
      final numberStr = className.substring(5); // "Manzu".length = 5
      if (numberStr.isNotEmpty && _isValidNumber(numberStr)) {
        return {'suit': 'm', 'number': numberStr};
      }
    }

    // 筒子 (Pinzu1~9)
    if (className.startsWith('Pinzu')) {
      final numberStr = className.substring(5); // "Pinzu".length = 5
      if (numberStr.isNotEmpty && _isValidNumber(numberStr)) {
        return {'suit': 'p', 'number': numberStr};
      }
    }

    // 索子 (Souzu1~9)
    if (className.startsWith('Souzu')) {
      final numberStr = className.substring(5); // "Souzu".length = 5
      if (numberStr.isNotEmpty && _isValidNumber(numberStr)) {
        return {'suit': 's', 'number': numberStr};
      }
    }

    // 字牌 処理
    final jihai = _parseJihaiClassName(className);
    if (jihai != null) {
      return {'suit': 'z', 'number': jihai};
    }

    return null;
  }

  /// 字牌 className をパース
  /// 例: "Ton" -> "1", "Haku" -> "5"
  static String? _parseJihaiClassName(String className) {
    switch (className) {
      case 'Ton': // 東
        return '1';
      case 'Nan': // 南
        return '2';
      case 'Sha': // 西
        return '3';
      case 'Pei': // 北
        return '4';
      case 'Haku': // 白
        return '5';
      case 'Hatsu': // 發
        return '6';
      case 'Chun': // 中
        return '7';
      default:
        return null;
    }
  }

  /// 有効な数字かチェック
  static bool _isValidNumber(String numberStr) {
    final number = int.tryParse(numberStr);
    return number != null && number >= 1 && number <= 9;
  }
}