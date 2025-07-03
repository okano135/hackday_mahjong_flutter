import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong_app/dora_state.dart';
import 'package:mahjong_app/hand_state.dart';
import 'package:mahjong_app/presentation/home/widgets/imageBackgroundButton.dart';

// --- ダイアログの状態管理用Enum ---
enum RiichiState { declared, notDeclared }

enum WinningMethod { tsumo, ron }

enum Wind { east, south, west, north }

/// Enumの表示名を返すヘルパー関数
String _getDisplayText(dynamic enumValue) {
  switch (enumValue) {
    case RiichiState.declared:
      return 'した';
    case RiichiState.notDeclared:
      return 'しなかった';
    case WinningMethod.tsumo:
      return 'ツモ';
    case WinningMethod.ron:
      return 'ロン';
    case Wind.east:
      return '東';
    case Wind.south:
      return '南';
    case Wind.west:
      return '西';
    case Wind.north:
      return '北';
    default:
      return '';
  }
}

/// 牌のクラス名から画像パスを返すヘルパー関数
String getTileImagePath(String tileName) {
  // 例: tileNameが "Man1" なら "assets/tiles/Man1.png" を返す
  // このマッピングはご自身の牌画像の命名規則に合わせてください
  return 'assets/pis/$tileName.png';
}

/// 点数計算ダイアログ本体
class ScoreCalculatorDialog extends ConsumerStatefulWidget {
  const ScoreCalculatorDialog({super.key});

  @override
  ConsumerState<ScoreCalculatorDialog> createState() =>
      _ScoreCalculatorDialogState();
}

class _ScoreCalculatorDialogState extends ConsumerState<ScoreCalculatorDialog> {
  // ダイアログ内のローカルな選択状態
  RiichiState _riichi = RiichiState.notDeclared;
  WinningMethod _winningMethod = WinningMethod.tsumo;
  Wind _playerWind = Wind.east;
  Wind _prevalentWind = Wind.east;
  String? _selectedWinningTile;

  @override
  Widget build(BuildContext context) {
    // Riverpodから手牌とドラの情報を取得
    final hand = ref.watch(handProvider);
    final dora = ref.watch(doraProvider);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '点数計算をするために、いくつかの質問に答えてください。',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('立直'),
                        const SizedBox(width: 100),
                        _buildSectionTitle('ドラ'),
                        const SizedBox(width: 100),
                        _buildSectionTitle('アガリ方'),
                        const SizedBox(width: 100),
                        _buildSectionTitle('自風'),
                        const SizedBox(width: 100),
                        _buildSectionTitle('場風'),
                        const SizedBox(width: 100),
                        _buildSectionTitle('アガリ牌'),
                      ],
                    ),
                    const SizedBox(width: 100),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildToggleGroup<RiichiState>(
                          options: RiichiState.values,
                          selectedValue: _riichi,
                          onSelected: (value) =>
                              setState(() => _riichi = value),
                        ),
                        _buildDoraSection(dora),
                        const SizedBox(height: 10),
                        _buildToggleGroup<WinningMethod>(
                          options: WinningMethod.values,
                          selectedValue: _winningMethod,
                          onSelected: (value) =>
                              setState(() => _winningMethod = value),
                        ),
                        const SizedBox(height: 10),
                        _buildToggleGroup<Wind>(
                          options: Wind.values,
                          selectedValue: _playerWind,
                          onSelected: (value) =>
                              setState(() => _playerWind = value),
                        ),
                        const SizedBox(height: 10),
                        _buildToggleGroup<Wind>(
                          options: const [Wind.east, Wind.south],
                          selectedValue: _prevalentWind,
                          onSelected: (value) =>
                              setState(() => _prevalentWind = value),
                        ),
                        const SizedBox(height: 25),
                        _buildWinningTileSelector(hand),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // --- 画像付き計算ボタン ---
                Center(
                  child: ImageBackgroundButton(
                    onPressed: () {},
                    text: "",
                    imagePath: "assets/button_calc.png",
                  ),
                ),

                // Center(
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: const Color(0xffE91E63),
                //       foregroundColor: Colors.white,
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 50,
                //         vertical: 14,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       textStyle: const TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //     onPressed: _selectedWinningTile == null
                //         ? null
                //         : () {
                //             // doraProviderから最新のドラリストを取得して計算処理へ
                //             final currentDora = ref.read(doraProvider);
                //             debugPrint('--- 計算データ ---');
                //             debugPrint('ドラ: $currentDora');
                //             debugPrint('立直: $_riichi');
                //             debugPrint('アガリ方: $_winningMethod');
                //             debugPrint('自風: $_playerWind');
                //             debugPrint('場風: $_prevalentWind');
                //             debugPrint('アガリ牌: $_selectedWinningTile');
                //             debugPrint('-----------------');
                //             Navigator.of(context).pop();
                //           },
                //     child: const Text('計算する'),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ドラ表示・操作セクションのウィジェット (★新しく追加)
  Widget _buildDoraSection(List<String> dora) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 現在のドラ牌を表示するコンテナ
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: dora.isEmpty
                ? const Text(
                    "追加ボタンでドラを選択",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  )
                : Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: dora.map((tileName) {
                      return Tooltip(
                        message: 'タップして削除',
                        child: GestureDetector(
                          onTap: () {
                            // タップされた牌をdoraProviderから削除
                            ref
                                .read(doraProvider.notifier)
                                .removeDora(tileName);
                          },
                          child: Image.asset(
                            getTileImagePath(tileName),
                            height: 40,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        // ドラ追加ボタン
        OutlinedButton(
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            // TODO: ここで牌選択用のダイアログなどを表示する
            // 例として、ここでは固定の牌（中）を追加する
            ref.read(doraProvider.notifier).addDora('Chun');
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white54),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  /// セクションタイトル用の共通ウィジェット
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0, bottom: 17.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 選択肢グループ用の共通ウィジェット
  Widget _buildToggleGroup<T>({
    required List<T> options,
    required T selectedValue,
    required ValueChanged<T> onSelected,
  }) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0, // 縦方向のスペースを調整
      children: options.map((option) {
        final isSelected = option == selectedValue;

        final iconWidget = _getToggleIcon(option, isSelected);

        return ChoiceChip(
          avatar: iconWidget,

          label: Text(_getDisplayText(option)),

          // アイコンとラベルの間の余白を調整
          labelPadding: const EdgeInsets.only(left: 4, right: 8),

          selected: isSelected,
          onSelected: (_) => onSelected(option),
          backgroundColor: Colors.transparent,
          selectedColor: Colors.transparent,
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          showCheckmark: false,
          side: BorderSide.none,
          elevation: isSelected ? 4 : 0,
        );
      }).toList(),
    );
  }

  Widget _getToggleIcon(dynamic option, bool isSelected) {
    // アイコン画像ファイル名を格納する変数
    String? assetName;

    if (isSelected) {
      assetName = "radioButton_pink.png";
    } else {
      assetName = "radioButton_default.png";
    }

    // assetNameが設定されていれば画像を表示し、なければ何も表示しない
    if (assetName != null) {
      return Image.asset('assets/$assetName', width: 20, height: 20);
    }

    // 対応するアイコンがない場合は空のコンテナを返す
    return const SizedBox.shrink();
  }

  /// アガリ牌を選択するウィジェット
  Widget _buildWinningTileSelector(List<String> hand) {
    if (hand.isEmpty) {
      return const Center(
        child: Text('手牌を検出できません', style: TextStyle(color: Colors.white54)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 4.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: hand.map((tileName) {
          final isSelected = tileName == _selectedWinningTile;
          return GestureDetector(
            onTap: () => setState(() => _selectedWinningTile = tileName),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: isSelected
                    ? Border.all(color: Colors.pink.shade300, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.pink.shade300.withOpacity(0.7),
                          blurRadius: 8,
                        ),
                      ]
                    : [],
              ),
              child: Image.asset(
                getTileImagePath(tileName),
                height: 50,
                fit: BoxFit.contain,
                // 画像がない場合に備えたフォールバック
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 50,
                    width: 38,
                    color: Colors.red[100],
                    alignment: Alignment.center,
                    child: Text(
                      tileName.substring(0, 2),
                      style: const TextStyle(fontSize: 9, color: Colors.black),
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
