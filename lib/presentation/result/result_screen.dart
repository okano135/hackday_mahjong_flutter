// lib/presentation/result/result_dialog.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mahjong_app/models/result_model.dart'; // 先ほど作成したモデルをインポート

class ResultDialog extends StatelessWidget {
  final MahjongResult result;

  const ResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 役一覧
              _buildYakuList(result.yaku),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.3)),
              const SizedBox(height: 16),
              // 合計点数
              _buildScoreSummary(result),
              const SizedBox(height: 24),
              // 支払い点数
              _buildPayoutDetails(result),
              const SizedBox(height: 32),
              // 閉じるボタン
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  backgroundColor: Colors.pink.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.pink),
                  ),
                ),
                child: const Text(
                  '閉じる',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 役一覧を生成するウィジェット
  Widget _buildYakuList(Map<String, String> yaku) {
    return Column(
      children: yaku.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.key,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                entry.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 飜数・符・合計点数を表示するウィジェット
  Widget _buildScoreSummary(MahjongResult result) {
    return Column(
      children: [
        Text(
          '${result.han}飜 ${result.fu}符',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${result.ten}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '点',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 支払い点数の内訳を表示するウィジェット
  Widget _buildPayoutDetails(MahjongResult result) {
    String payoutText;

    if (result.isTsumo) {
      if (result.isWinnerOya) {
        // 親のツモ和了
        payoutText = '${result.oya.first} オール';
      } else {
        // 子のツモ和了 (APIレスポンスの例はこちらに該当)
        payoutText = '${result.ko[0]} - ${result.ko[1]}'; // 親の支払い -子の支払い
      }
    } else {
      // ロン和了の場合
      payoutText = '放銃者から ${result.ten}点';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '支払い: $payoutText',
        style: const TextStyle(
          color: Colors.yellowAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
