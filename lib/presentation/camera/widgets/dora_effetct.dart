import 'package:flutter/material.dart';

class DoraEffect extends StatelessWidget {
  const DoraEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DoraPainter(),
    );
  }
}

class _DoraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.red,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      shadows: [
        const Shadow(
          blurRadius: 2.0,
          color: Colors.black26,
          offset: Offset(1.0, 1.0),
        ),
      ],
    );

    final textSpan = TextSpan(
      text: 'ドラ',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final x = (size.width - textPainter.width) / 2;
    final y = size.height - textPainter.height;
    final offset = Offset(x, y);

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}