import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong_app/hand_state.dart';

void showAgariHandDialog(BuildContext context, WidgetRef ref) {
  final handState = ref.watch(handProvider); // 推定手牌リストを取得
  print('Current hand state: $handState');
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) =>
        AgariHandEditor(initialHand: List<String>.from(handState)),
  );
}

class AgariHandEditor extends StatefulWidget {
  final List<String> initialHand;
  const AgariHandEditor({required this.initialHand});

  @override
  State<AgariHandEditor> createState() => _AgariHandEditorState();
}

class _AgariHandEditorState extends State<AgariHandEditor> {
  late List<String> handTiles; // 下部：現在の手牌
  final Map<String, int> selectedCounts = {};
  final allTiles = [
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

  @override
  void initState() {
    super.initState();
    handTiles = List<String>.from(widget.initialHand)..sort();
    for (final tile in allTiles) {
      selectedCounts[tile] = handTiles.where((t) => t == tile).length;
    }
  }

  void addTile(String tile) {
    if ((selectedCounts[tile] ?? 0) < 4 && handTiles.length < 14) {
      setState(() {
        handTiles.add(tile);
        selectedCounts[tile] = (selectedCounts[tile] ?? 0) + 1;
        handTiles.sort();
      });
    }
  }

  void removeTile(String tile) {
    setState(() {
      handTiles.remove(tile);
      selectedCounts[tile] = (selectedCounts[tile] ?? 1) - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上部：牌選択リスト
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allTiles.length,
              separatorBuilder: (_, __) => SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final tile = allTiles[idx];
                final count = selectedCounts[tile] ?? 0;
                return GestureDetector(
                  onTap: () => addTile(tile),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 40,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                        child: Image.asset(
                          'assets/pis/$tile.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // 下部：推定手牌リスト
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: handTiles
                .map(
                  (tile) => GestureDetector(
                    onTap: () => removeTile(tile),
                    child: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.lightBlue[50],
                      ),
                      child: Image.asset(
                        'assets/pis/$tile.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(handTiles),
                child: Image.asset(
                  'assets/button_finish.png',
                  width: 120, // お好みで調整
                  height: 48,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
