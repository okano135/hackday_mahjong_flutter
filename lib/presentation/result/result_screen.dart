import 'dart:ui';

// --- ユーザー提供のProvider ---
// このProviderが定義されているファイルをインポートしてください
// import 'path/to/your/hand_provider.dart';

// (ユーザー提供のコードをここに含めます)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 点数計算ダイアログ本体
class ScoreCalculatorDialog extends ConsumerStatefulWidget {
  const ScoreCalculatorDialog({super.key});

  @override
  ConsumerState<ScoreCalculatorDialog> createState() =>
      _ScoreCalculatorDialogState();
}

class _ScoreCalculatorDialogState extends ConsumerState<ScoreCalculatorDialog> {
  // ダイアログ内の選択状態を管理する変数
  RiichiState _riichi = RiichiState.notDeclared;
  WinningMethod _winningMethod = WinningMethod.tsumo;
  Wind _playerWind = Wind.east;
  Wind _prevalentWind = Wind.east;
  String? _selectedWinningTile;
  // TODO: ドラのリストを管理する状態を追加
  // List<String> _doraTiles = [];

  @override
  Widget build(BuildContext context) {
    // Riverpodから手牌の情報を取得
    final hand = ref.watch(handProvider);

    // 背景をぼかすためのウィジェット
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            // 内容が多くなってもスクロールできるようにする
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ヘッダーテキスト ---
                const Text(
                  '点数計算をするために、いくつかの質問に答えてください。',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),

                // --- 各入力セクション ---
                _buildSectionTitle('立直'),
                _buildToggleGroup<RiichiState>(
                  options: RiichiState.values,
                  selectedValue: _riichi,
                  onSelected: (value) => setState(() => _riichi = value),
                ),

                _buildSectionTitle('ドラ'),
                // NOTE: ドラ選択機能は要件に合わせて実装が必要です
                Row(
                  children: [
                    Image.asset(
                      getTileImagePath('Man1'),
                      height: 40,
                    ), // ドラ表示牌の例
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        '追加',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        /* TODO: ドラ追加のロジックを実装 */
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),

                _buildSectionTitle('アガリ方'),
                _buildToggleGroup<WinningMethod>(
                  options: WinningMethod.values,
                  selectedValue: _winningMethod,
                  onSelected: (value) => setState(() => _winningMethod = value),
                ),

                _buildSectionTitle('自風'),
                _buildToggleGroup<Wind>(
                  options: Wind.values,
                  selectedValue: _playerWind,
                  onSelected: (value) => setState(() => _playerWind = value),
                ),

                _buildSectionTitle('場風'),
                _buildToggleGroup<Wind>(
                  options: const [Wind.east, Wind.south], // 一般的な場風
                  selectedValue: _prevalentWind,
                  onSelected: (value) => setState(() => _prevalentWind = value),
                ),

                _buildSectionTitle('アガリ牌'),
                _buildWinningTileSelector(hand),

                const SizedBox(height: 32),

                // --- 計算ボタン ---
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffE91E63), // Pink
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _selectedWinningTile == null
                        ? null
                        : () {
                            // 全ての選択結果を使って計算処理を実行
                            // ここでは結果をコンソールに出力
                            debugPrint('--- 計算データ ---');
                            debugPrint('立直: $_riichi');
                            debugPrint('アガリ方: $_winningMethod');
                            debugPrint('自風: $_playerWind');
                            debugPrint('場風: $_prevalentWind');
                            debugPrint('アガリ牌: $_selectedWinningTile');
                            debugPrint('-----------------');
                            Navigator.of(context).pop(); // ダイアログを閉じる
                          },
                    child: const Text('計算する'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// セクションタイトル用の共通ウィジェット
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
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
      children: options.map((option) {
        final isSelected = option == selectedValue;
        return ChoiceChip(
          label: Text(_getDisplayText(option)),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          backgroundColor: Colors.grey.shade800,
          selectedColor: Colors.teal.shade300,
          labelStyle: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
          showCheckmark: false,
          side: BorderSide.none,
          elevation: isSelected ? 4 : 0,
        );
      }).toList(),
    );
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
