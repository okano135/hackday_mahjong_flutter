// lib/main.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong_app/dora_state.dart';
import 'package:mahjong_app/hand_state.dart';
import 'package:mahjong_app/presentation/camera/widgets/score_calculator_dialog.dart';
import 'package:ultralytics_yolo/yolo_streaming_config.dart';
import 'package:ultralytics_yolo/yolo_task.dart';
import 'package:ultralytics_yolo/yolo_view.dart';

import 'widgets/agari_hand_editor.dart';
import 'widgets/dora_image_effect.dart'; // ドラのきらめきエフェクトを表示するWidget
import 'widgets/dora_selection.dart';

class AdvancedCameraScreen extends ConsumerStatefulWidget {
  const AdvancedCameraScreen({super.key}); // keyを追加するのが一般的です

  @override
  // ConsumerState を返すように変更します
  ConsumerState<AdvancedCameraScreen> createState() =>
      _AdvancedCameraScreenState();
}

// State<AdvancedCameraScreen> の代わりに ConsumerState<AdvancedCameraScreen> を継承します
class _AdvancedCameraScreenState extends ConsumerState<AdvancedCameraScreen> {
  List<dynamic> _currentDetections = [];
  Size _viewSize = Size.zero;

  @override
  // build メソッドの引数は BuildContext のみになります。
  // `ref` は ConsumerState のプロパティとして `this.ref` でアクセスできます。
  Widget build(BuildContext context) {
    final doraTiles = ref.watch(doraProvider);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          _viewSize = Size(constraints.maxWidth, constraints.maxHeight);

          return Stack(
            children: [
              YOLOView(
                modelPath: 'best_re',
                task: YOLOTask.detect,
                // Configure streaming behavior
                streamingConfig: YOLOStreamingConfig.throttled(
                  maxFPS: 15, // Limit to 15 FPS for battery saving
                  includeMasks: false, // Disable masks for performance
                  includeOriginalImage: false, // Save bandwidth
                ),

                // Comprehensive callback
                onStreamingData: (data) {
                  final detections = data['detections'] as List? ?? [];
                  final fps = data['fps'] as double? ?? 0.0;
                  final originalImage = data['originalImage'] as Uint8List?;

                  // Notifier を通じて手牌の状態を更新
                  ref.watch(handProvider.notifier).updateHand(detections);

                  // Update detections for overlay
                  setState(() {
                    _currentDetections = detections;
                  });

                  // Process complete frame data
                  processFrameData(detections, originalImage);
                },
              ),
              ..._buildDetectionOverlays(),
              Positioned(
                left: 24,
                bottom: 24,
                child: GestureDetector(
                  onTap: () {
                    // showAgariHandDialog(context, ref);
                    editHandAndCalculate(context, ref);
                  },
                  child: Image.asset(
                    'assets/button_agari.png',
                    width: 144, // お好みで調整
                    height: 144,
                  ),
                ),
              ),
              Positioned(
                top: 16, // ステータスバーとの余白
                left: 16, // 画面の左端からの余白
                child: DoraSelection(
                  label: 'ドラ入力',
                  onTap: () => showDoraDialog(context),
                ),
              ),
              if (doraTiles.isNotEmpty)
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0), // ステータスバーとの余白
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6), // 薄黒い背景
                        borderRadius: BorderRadius.circular(20), // 角を丸くする
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // 中身のサイズに合わせる
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Image.asset(
                              'assets/dora_animation.gif', // アニメーションGIFのパス
                              height: 40,
                            ),
                          ),
                          // 選択されたドラ牌の画像を表示
                          ...doraTiles.map((tile) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2.0,
                              ),
                              child: Image.asset(
                                'assets/pis/$tile.png',
                                height: 40, // 画像の高さ
                                width: 28, // 画像の幅
                              ),
                            );
                          }).toList(),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Image.asset(
                              'assets/dora_animation.gif', // アニメーションGIFのパス
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildDetectionOverlays() {
    if (_currentDetections.isEmpty || _viewSize == Size.zero) {
      return [];
    }
    List<Widget> overlays = [];
    for (final detection in _currentDetections) {
      // 検出データのキー 'box' はモデルの出力によって異なる場合があります。
      // 'box', 'rect' など、実際のキーに合わせてください。
      final box = detection['normalizedBox'] as Map?;
      final className = detection['className'] as String?;
      final confidence = detection['confidence'] as double?;
      if (box == null || className == null || confidence == null) continue;

      List<String> doraList = ref.watch(doraProvider);
      if (doraList.contains(className)) {
        final left = (box['left'] as num).toDouble();
        final top = (box['top'] as num).toDouble();
        final right = (box['right'] as num).toDouble();
        final bottom = (box['bottom'] as num).toDouble();
        print("🀄 Manzu4 Detection: $left , $top , $right , $bottom");
        overlays.add(
          Positioned(
            left: left * _viewSize.width,
            top: top * _viewSize.height,
            width: (right - left) * _viewSize.width,
            height: (bottom - top) * _viewSize.height,
            child: DoraEffect(
              width: (right - left) * _viewSize.width,
            ), // 後で実装するきらめきエフェクトのWidget
          ),
        );
      }
    }
    return overlays;
  }

  void processFrameData(List detections, Uint8List? imageData) {
    // Custom processing logic
    for (final detection in detections) {
      final className = detection['className'] as String?;
      final confidence = detection['confidence'] as double?;

      // Debug: Print only Manzu4 detection structure
      if (className == 'Manzu4') {
        //print('🀄 Manzu4 Detection Full Structure: $detection');

        // Check all possible box key names
        final possibleBoxKeys = ['box', 'boundingBox', 'rect', 'bounds'];
        for (final key in possibleBoxKeys) {
          if (detection.containsKey(key)) {
            //print('📦 Found box data in key "$key": ${detection[key]}');
          }
        }
      }
    }
  }
}

// 仮のshowAgariHandDialogの定義。実際のものに置き換えてください。
// Future<List<String>?> showAgariHandDialog(
//   BuildContext context,
//   WidgetRef ref,
// ) async {
//   // この中で手牌編集ダイアログを表示し、
//   // 完了したら手牌のリストを返す（キャンセルならnull）
//   // 以下はダミーの実装
//   await Future.delayed(const Duration(seconds: 1)); // 編集時間をシミュレート
//   return [
//     'Manzu1',
//     'Manzu2',
//     'Manzu3',
//     'Manzu4',
//     'Manzu5',
//     'Manzu6',
//     'Manzu7',
//     'Manzu8',
//     'Manzu9',
//     'Manzu1',
//     'Manzu2',
//     'Manzu3',
//     'Manzu4',
//     'Manzu5',
//   ];
// }

/// 手牌編集と点数計算を実行する関数
void editHandAndCalculate(BuildContext context, WidgetRef ref) async {
  // 1. 手牌編集ダイアログを表示
  final updatedHand = await showAgariHandDialog(context, ref);

  // 2. 手牌が設定された場合のみ、点数計算ダイアログを表示
  if (updatedHand != null && context.mounted) {
    // context.mountedでウィジェットが有効かチェック
    showDialog(
      context: context,
      builder: (context) {
        return ScoreCalculatorDialog(hand: updatedHand);
      },
    );
  }
}

class _DialogButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _DialogButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
      onPressed: onTap,
    );
  }
}

void showDoraDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => DoraDialog());
}

class DoraDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<DoraDialog> createState() => _DoraDialogState();
}

class _DoraDialogState extends ConsumerState<DoraDialog> {
  final tiles = [
    // マンズ (萬子)
    'Manzu1',
    'Manzu2',
    'Manzu3',
    'Manzu4',
    'Manzu5',
    'Manzu6',
    'Manzu7',
    'Manzu8',
    'Manzu9',

    // ピンズ (筒子)
    'Pinzu1',
    'Pinzu2',
    'Pinzu3',
    'Pinzu4',
    'Pinzu5',
    'Pinzu6',
    'Pinzu7',
    'Pinzu8',
    'Pinzu9',

    // ソウズ (索子)
    'Sowzu1',
    'Sowzu2',
    'Sowzu3',
    'Sowzu4',
    'Sowzu5',
    'Sowzu6',
    'Sowzu7',
    'Sowzu8',
    'Sowzu9',

    // 字牌 (風牌・三元牌)
    'Etc_East',
    'Etc_South',
    'Etc_West',
    'Etc_North',
    'Etc_White',
    'Etc_Hatsu',
    'Etc_Center',
  ];

  final selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tiles.map((tile) {
                final isSelected = selected.contains(tile);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selected.remove(tile);
                      } else if (selected.length < 5) {
                        selected.add(tile);
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black12),
                      color: isSelected ? Colors.yellowAccent : Colors.white,
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(color: Colors.yellow, blurRadius: 4),
                      ],
                    ),
                    width: 40,
                    height: 60,
                    child: Image.asset(
                      'assets/pis/$tile.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  // ドラの状態をリセット
                  ref.read(doraProvider.notifier).clearDora();

                  // 選択されたドラを追加
                  for (final dora in selected) {
                    ref.read(doraProvider.notifier).addDora(dora);
                  }

                  Navigator.of(context).pop(selected.toList());
                  //refの状態を確認する
                  print("Selected Dora: ${ref.read(doraProvider)}");
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    '🌸 完了 🌸',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
