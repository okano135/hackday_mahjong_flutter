import 'package:flutter/material.dart';

class ImageBackgroundButton extends StatelessWidget {
  const ImageBackgroundButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.imagePath,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final String imagePath; // 画像のパス

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed, // タップされたときの処理
      child: Container(
        width: 200, // ボタンの幅
        height: 60, // ボタンの高さ
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover, // 画像の表示方法（cover: 全体を覆う, fill: 引き伸ばすなど）
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white, // テキストの色
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
