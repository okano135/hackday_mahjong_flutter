// lib/domain/services/mahjong_logic_service.dart
import 'dart:ui';

import '../../data/models/detection_result.dart';
import '../../data/models/mahjong_models.dart'; // 変更: インポートパスを修正

/// 麻雀のルールに基づいたロジックを処理するサービスクラス
class MahjongLogicService {
  /// 検出結果からゲーム状態を構築する
  MahjongGameState processDetections(
    List<DetectionResult> detections,
    Size screenSize,
  ) {
    // 領域ベースで牌の役割を判定
    // 例: 画面下部1/3を手牌領域、右上隅をドラ表示牌領域とする
    final handRegion = Rect.fromLTWH(
      0,
      screenSize.height * 2 / 3,
      screenSize.width,
      screenSize.height / 3,
    );
    final doraRegion = Rect.fromLTWH(
      screenSize.width * 0.7,
      0,
      screenSize.width * 0.3,
      screenSize.height * 0.2,
    );

    final List<LocatedPai> locatedHand = [];
    LocatedPai? locatedDoraIndicator;

    for (final detection in detections) {
      final pai = _mapLabelToPai(detection.label);
      if (pai == null) continue;

      final locatedPai = LocatedPai(pai: pai, position: detection.boundingBox);

      // 牌の中心点がどの領域にあるかで役割を判断
      if (handRegion.contains(detection.boundingBox.center)) {
        locatedHand.add(locatedPai);
      } else if (doraRegion.contains(detection.boundingBox.center)) {
        // ドラ表示牌は最も信頼度が高いものを1つだけ選ぶ
        if (locatedDoraIndicator == null || detection.confidence > 0.8) {
          // 仮のロジック
          locatedDoraIndicator = locatedPai;
        }
      }
    }

    // ドラを計算
    final List<Pai> dora = (locatedDoraIndicator != null)
        ? _calculateDora(locatedDoraIndicator.pai)
        : [];

    // 手牌の各牌がドラかどうかをマーク
    for (final p in locatedHand) {
      if (dora.any((d) => d.id == p.pai.id)) {
        p.pai.isDora = true;
      }
    }

    // [重要] ここでシャンテン数計算を行い、打牌候補を決定する
    // 実際のアプリでは、ここに専門のライブラリを使った複雑な計算が入る
    _calculateCandidates(locatedHand);

    return MahjongGameState(
      hand: locatedHand,
      doraIndicator: locatedDoraIndicator,
      dora: dora,
    );
  }

  /// ラベルIDからPaiオブジェクトに変換する (サンプル実装)
  Pai? _mapLabelToPai(String label) {
    // 本来は全ての牌のマッピングを定義する
    // 例: "man1" -> Pai(id: "man1", displayName: "一萬")
    // ここでは簡略化のため、ラベルをそのままIDと表示名に使う
    if (label.isNotEmpty) {
      return Pai(id: label, displayName: label);
    }
    return null;
  }

  /// ドラ表示牌からドラを計算する (サンプル実装)
  List<Pai> _calculateDora(Pai indicator) {
    // TODO: 実際の麻雀ルールに従ったドラ計算ロジックを実装
    // 例: "man1" -> "man2", "pin9" -> "pin1", "haku" -> "hatsu"
    return [Pai(id: indicator.id, displayName: indicator.displayName)]; // 仮実装
  }

  /// 打牌候補を計算する (サンプル実装)
  void _calculateCandidates(List<LocatedPai> hand) {
    // [重要] ここはシャンテン数計算ロジックに置き換えるべき部分
    // このサンプルでは、単純に孤立している牌を候補とする
    if (hand.length > 2) {
      // 仮ロジックとして、ランダムに1枚を候補にする
      final candidateIndex = DateTime.now().millisecond % hand.length;
      hand[candidateIndex].pai.isCandidate = true;
    }
  }
}
