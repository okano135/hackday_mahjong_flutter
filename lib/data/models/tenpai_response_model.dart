// lib/data/models/tenpai_response_model.dart

/// 텐파이 체크 응답 모델
class TenpaiResponseModel {
  final bool isTenpai;
  final List<String> agarihai;

  const TenpaiResponseModel({required this.isTenpai, required this.agarihai});

  factory TenpaiResponseModel.fromJson(Map<String, dynamic> json) {
    return TenpaiResponseModel(
      isTenpai: json['isTenpai'] as bool? ?? false,
      agarihai:
          (json['agarihai'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'isTenpai': isTenpai, 'agarihai': agarihai};
  }

  @override
  String toString() {
    return 'TenpaiResponseModel(isTenpai: $isTenpai, agarihai: $agarihai)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TenpaiResponseModel &&
        other.isTenpai == isTenpai &&
        _listEquals(other.agarihai, agarihai);
  }

  @override
  int get hashCode => isTenpai.hashCode ^ agarihai.hashCode;

  // List equality helper
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
