// lib/data/models/result_mapper.dart

import '../../../data/models/score_calculation_response_model.dart';
import 'result_model.dart'; // MahjongResultモデルのパス

// 'ScoreResult'クラスに'toMahjongResult'という変換メソッドを追加する
extension ScoreResultMapper on ScoreResult {
  /// ScoreResultオブジェクトをUIで使うMahjongResultオブジェクトに変換します。
  MahjongResult toMahjongResult() {
    return MahjongResult(
      isAgari: this.isAgari,
      yaku: this.yaku,
      han: this.han,
      fu: this.fu,
      ten: this.ten,
      text: this.text,
      oya: this.oya,
      ko: this.ko,
    );
  }
}
