// lib/data/models/score_calculation_response_model.dart
/// 点数計算API応答モデル
class ScoreCalculationResponseModel {
  /// 成功かどうか
  final bool success;

  /// 計算結果
  final ScoreResult result;

  /// エラーメッセージ
  final String? error;

  /// 入力情報
  final InputInfo input;

  const ScoreCalculationResponseModel({
    required this.success,
    required this.result,
    this.error,
    required this.input,
  });

  /// JSONから生成
  factory ScoreCalculationResponseModel.fromJson(Map<String, dynamic> json) {
    return ScoreCalculationResponseModel(
      success: json['success'] as bool,
      result: ScoreResult.fromJson(json['result'] as Map<String, dynamic>),
      error: json['error'] as String?,
      input: InputInfo.fromJson(json['input'] as Map<String, dynamic>),
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'result': result.toJson(),
      'error': error,
      'input': input.toJson(),
    };
  }

  /// 既存互換性のためのgetter
  ScoreInfo get currentScore {
    return ScoreInfo(
      baseScore: result.ten,
      han: result.han,
      fu: result.fu,
      finalScore: result.ten,
      yakuName: result.name,
    );
  }

  List<YakuInfo> get possibleYaku {
    return result.yakuInfoList;
  }

  String? get message {
    return result.text.isNotEmpty ? result.text : null;
  }
}

/// 点数計算結果
class ScoreResult {
  /// 和了かどうか
  final bool isAgari;

  /// 役満数
  final int yakuman;

  /// 役情報 (役名 -> 翻数)
  final Map<String, String> yaku;

  /// 総翻数
  final int han;

  /// 符数
  final int fu;

  /// 点数
  final int ten;

  /// 役名
  final String name;

  /// 説明テキスト
  final String text;

  /// 親の点数配分
  final List<int> oya;

  /// 子の点数配分
  final List<int> ko;

  /// エラーかどうか
  final bool error;

  const ScoreResult({
    required this.isAgari,
    required this.yakuman,
    required this.yaku,
    required this.han,
    required this.fu,
    required this.ten,
    required this.name,
    required this.text,
    required this.oya,
    required this.ko,
    required this.error,
  });

  /// JSONから生成
  factory ScoreResult.fromJson(Map<String, dynamic> json) {
    final yakuJson = json['yaku'] as Map<String, dynamic>? ?? {};
    final yaku = yakuJson.map((key, value) => MapEntry(key, value.toString()));

    return ScoreResult(
      isAgari: json['isAgari'] as bool,
      yakuman: json['yakuman'] as int,
      yaku: yaku,
      han: json['han'] as int,
      fu: json['fu'] as int,
      ten: json['ten'] as int,
      name: json['name'] as String? ?? '',
      text: json['text'] as String? ?? '',
      oya: List<int>.from(json['oya'] as List<dynamic>? ?? []),
      ko: List<int>.from(json['ko'] as List<dynamic>? ?? []),
      error: json['error'] as bool? ?? false,
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'isAgari': isAgari,
      'yakuman': yakuman,
      'yaku': yaku,
      'han': han,
      'fu': fu,
      'ten': ten,
      'name': name,
      'text': text,
      'oya': oya,
      'ko': ko,
      'error': error,
    };
  }

  /// 役一覧をYakuInfoリストに変換
  List<YakuInfo> get yakuInfoList {
    return yaku.entries.map((entry) {
      final yakuName = entry.key;
      final hanString = entry.value;

      // "2飜", "1飜" などから数字を抽出
      final hanMatch = RegExp(r'(\d+)').firstMatch(hanString);
      final han = hanMatch != null ? int.parse(hanMatch.group(1)!) : 0;

      return YakuInfo(
        name: yakuName,
        han: han,
        description: hanString,
        probability: 1.0, // 既に完成した役なので確率100%
      );
    }).toList();
  }
}

/// 入力情報
class InputInfo {
  /// 元の牌文字列
  final String originalHand;

  /// 処理された牌文字列
  final String processedHand;

  /// オプション情報
  final OptionsInfo options;

  const InputInfo({
    required this.originalHand,
    required this.processedHand,
    required this.options,
  });

  /// JSONから生成
  factory InputInfo.fromJson(Map<String, dynamic> json) {
    return InputInfo(
      originalHand: json['originalHand'] as String,
      processedHand: json['processedHand'] as String,
      options: OptionsInfo.fromJson(json['options'] as Map<String, dynamic>),
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'originalHand': originalHand,
      'processedHand': processedHand,
      'options': options.toJson(),
    };
  }
}

/// オプション情報
class OptionsInfo {
  /// ドラ情報
  final List<String> dora;

  /// 追加情報
  final dynamic extra;

  /// 風情報
  final String? wind;

  /// ダブル役満無効化
  final bool disableWyakuman;

  /// 喰いタン無効化
  final bool disableKuitan;

  /// 赤ドラ無効化
  final bool disableAka;

  /// ローカル役有効化
  final List<String> enableLocalYaku;

  /// 無効化された役
  final List<String> disableYaku;

  const OptionsInfo({
    required this.dora,
    this.extra,
    this.wind,
    required this.disableWyakuman,
    required this.disableKuitan,
    required this.disableAka,
    required this.enableLocalYaku,
    required this.disableYaku,
  });

  /// JSONから生成
  factory OptionsInfo.fromJson(Map<String, dynamic> json) {
    return OptionsInfo(
      dora: List<String>.from(json['dora'] as List<dynamic>? ?? []),
      extra: json['extra'],
      wind: json['wind'] as String?,
      disableWyakuman: json['disableWyakuman'] as bool? ?? false,
      disableKuitan: json['disableKuitan'] as bool? ?? false,
      disableAka: json['disableAka'] as bool? ?? false,
      enableLocalYaku: List<String>.from(
        json['enableLocalYaku'] as List<dynamic>? ?? [],
      ),
      disableYaku: List<String>.from(
        json['disableYaku'] as List<dynamic>? ?? [],
      ),
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'dora': dora,
      'extra': extra,
      'wind': wind,
      'disableWyakuman': disableWyakuman,
      'disableKuitan': disableKuitan,
      'disableAka': disableAka,
      'enableLocalYaku': enableLocalYaku,
      'disableYaku': disableYaku,
    };
  }
}

/// 点数情報 (既存互換性のため維持)
class ScoreInfo {
  /// 基本点数
  final int baseScore;

  /// 翻数 (飜)
  final int han;

  /// 符数
  final int fu;

  /// 最終点数
  final int finalScore;

  /// 役名
  final String? yakuName;

  const ScoreInfo({
    required this.baseScore,
    required this.han,
    required this.fu,
    required this.finalScore,
    this.yakuName,
  });

  /// JSONから生成
  factory ScoreInfo.fromJson(Map<String, dynamic> json) {
    return ScoreInfo(
      baseScore: json['baseScore'] as int,
      han: json['han'] as int,
      fu: json['fu'] as int,
      finalScore: json['finalScore'] as int,
      yakuName: json['yakuName'] as String?,
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'baseScore': baseScore,
      'han': han,
      'fu': fu,
      'finalScore': finalScore,
      'yakuName': yakuName,
    };
  }
}

/// 役情報 (既存互換性のため維持)
class YakuInfo {
  /// 役名
  final String name;

  /// 翻数 (飜)
  final int han;

  /// 役説明
  final String description;

  /// 完成確率 (0.0 ~ 1.0)
  final double probability;

  const YakuInfo({
    required this.name,
    required this.han,
    required this.description,
    required this.probability,
  });

  /// JSONから生成
  factory YakuInfo.fromJson(Map<String, dynamic> json) {
    return YakuInfo(
      name: json['name'] as String,
      han: json['han'] as int,
      description: json['description'] as String,
      probability: (json['probability'] as num).toDouble(),
    );
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'han': han,
      'description': description,
      'probability': probability,
    };
  }
}
