// lib/presentation/camera/widgets/detection_painter.dart
import 'package:flutter/material.dart';

import '../../../data/models/mahjong_models.dart'; // 変更: インポートパスを修正

class DetectionPainter extends CustomPainter {
  final MahjongGameState gameState;
  // final bool isProcessing;

  DetectionPainter({required this.gameState /*, required this.isProcessing*/});

  @override
  void paint(Canvas canvas, Size size) {
    // ドラ表示牌を描画
    if (gameState.doraIndicator != null) {
      _drawBox(canvas, gameState.doraIndicator!.position, Colors.amber, 'ドラ表示');
    }

    // 手牌を描画
    for (final locatedPai in gameState.hand) {
      Color color = Colors.green.shade300;
      String? topLabel;

      if (locatedPai.pai.isDora) {
        color = Colors.red.shade400;
        topLabel = 'ドラ';
      }
      if (locatedPai.pai.isCandidate) {
        color = Colors.lightBlueAccent;
        topLabel = '打牌候補';
      }
      _drawBox(canvas, locatedPai.position, color, topLabel);
    }
  }

  void _drawBox(Canvas canvas, Rect box, Color color, String? topLabel) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRect(box, paint);

    if (topLabel != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: topLabel,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black.withOpacity(0.6),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(box.left, box.top - textPainter.height));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 常に再描画
  }
}
