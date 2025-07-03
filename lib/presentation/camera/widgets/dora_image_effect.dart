import 'dart:ui' as ui; // ui.Image を使用するために必要
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle を使用するために必要

class DoraEffect extends StatefulWidget {
  // 1. widthプロパティを追加
  final double width;

  const DoraEffect({
    super.key,
    required this.width, // widthを必須パラメータにする
  });

  @override
  State<DoraEffect> createState() => _DoraEffectState();
}

class _DoraEffectState extends State<DoraEffect> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  // initStateは非同期にできないため、別の非同期メソッドを用意する
  Future<void> _loadImage() async {
    final byteData = await rootBundle.load('assets/dora_bg.png'); // あなたの画像パスを指定
    final bytes = byteData.buffer.asUint8List();
    final image = await decodeImageFromList(bytes);
    // マウントされている場合のみsetStateを呼ぶ
    if (mounted) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 画像が読み込まれるまでは何も表示しない（またはローディング表示）
    if (_image == null) {
      return SizedBox(width: widget.width); // 初期サイズを確保
    }

    // 2. 画像の縦横比を計算
    final imageAspectRatio = _image!.width / _image!.height;
    // 渡されたwidthから、縦横比を維持した高さを計算
    final height = widget.width / imageAspectRatio;

    // 3. SizedBoxでCustomPaintのサイズを明示的に指定
    return SizedBox(
      width: widget.width,
      height: height,
      child: CustomPaint(
        painter: _DoraPainter(image: _image),
        // CustomPaintはデフォルトでサイズ0x0なので、サイズを指定する
        size: Size(widget.width, height),
      ),
    );
  }
}

class _DoraPainter extends CustomPainter {
  final ui.Image? image;

  _DoraPainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final paint = Paint()..color = Colors.white.withOpacity(1.0);

    // 4. 与えられたsize全体に画像を描画するよう修正
    final sourceRect = Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble());
    final destinationRect = Offset.zero & size; // (0,0)から(size.width, size.height)の矩形

    canvas.drawImageRect(
      image!,
      sourceRect,
      destinationRect,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DoraPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}