import 'dart:ui';
import 'package:flutter/material.dart';


class DoraSelection extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const DoraSelection({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // GestureDetectorでタップイベントを処理します
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        // 全ての要素（背景、シャドウ）に角丸を適用するため、親ウィジェットでクリップします
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          // ボタン全体の装飾（主に外側のドロップシャドウ）
          decoration: BoxDecoration(
            boxShadow: [
              // ドロップシャドウ1つ目
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.15),
                offset: const Offset(-11.15, -10.39),
                blurRadius: 48.0,
                spreadRadius: -12.0,
              ),
              // ドロップシャドウ2つ目
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.15),
                offset: const Offset(-1.86, -1.73),
                blurRadius: 12.0,
                spreadRadius: -8.0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 背景（すりガラス効果）
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  // BackdropFilterを有効にするために透明なコンテナを配置します
                  color: Colors.transparent,
                ),
              ),

              // レイヤー1: 背景の塗り
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF).withOpacity(0.10),
                ),
              ),

              // レイヤー2: インナーシャドウ（グラデーションで擬似的に表現）
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFFFFF).withOpacity(0.15), // インナーシャドウ1
                      const Color(0xFFFFFFFF).withOpacity(0.15), // インナーシャドウ2
                      Colors.transparent,
                    ],
                    // stopsでグラデーションの範囲を調整し、シャドウのサイズやぼかしを表現
                    stops: const [0.0, 0.1, 0.6],
                  ),
                ),
              ),

              // レイヤー3: ボタンのラベル
              Padding(
                // paddingでテキストの周りに余白を作ります
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Center(
                  child: Text(
                    label, // コンストラクタから受け取ったテキストを使用
                    style: const TextStyle(
                      color: Colors.white, // 見やすいように文字色を白に設定
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}