// lib/models/result_model.dart

/// APIレスポンス全体を表現するクラス
class ApiResponse {
  final bool success;
  final MahjongResult result;

  ApiResponse({required this.success, required this.result});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      result: MahjongResult.fromJson(json['result']),
    );
  }
}

/// 和了結果(`result`オブジェクト)を表現するクラス
class MahjongResult {
  final bool isAgari;
  final Map<String, String> yaku;
  final int han;
  final int fu;
  final int ten;
  final String text;
  final List<int> oya; // 親の支払い
  final List<int> ko; // 子の支払い

  MahjongResult({
    required this.isAgari,
    required this.yaku,
    required this.han,
    required this.fu,
    required this.ten,
    required this.text,
    required this.oya,
    required this.ko,
  });

  /// JSONからMahjongResultオブジェクトを生成するfactoryコンストラクタ
  factory MahjongResult.fromJson(Map<String, dynamic> json) {
    // yakuのMapを<String, String>に変換
    final Map<String, String> yakuMap = (json['yaku'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value.toString()));

    // oya, ko のListを<int>に変換
    final List<int> oyaList = List<int>.from(json['oya'] ?? []);
    final List<int> koList = List<int>.from(json['ko'] ?? []);

    return MahjongResult(
      isAgari: json['isAgari'] ?? false,
      yaku: yakuMap,
      han: json['han'] ?? 0,
      fu: json['fu'] ?? 0,
      ten: json['ten'] ?? 0,
      text: json['text'] ?? '',
      oya: oyaList,
      ko: koList,
    );
  }

  /// テキスト情報から和了者が親か子かを判定するヘルパー
  bool get isWinnerOya {
    // 例: "(東場東家)自摸..." のように "東家" (親) が含まれるかチェック
    // より堅牢にするには、ルールの詳細に応じて判定ロジックを調整してください
    return text.contains('東家');
  }

  /// テキスト情報からツモ和了かロン和了かを判定するヘルパー
  bool get isTsumo {
    return text.contains('自摸');
  }
}
