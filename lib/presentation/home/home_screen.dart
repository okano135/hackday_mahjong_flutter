import 'package:flutter/material.dart';
import 'package:mahjong_app/presentation/result/result_screen.dart';

import '../camera/widgets/imageBackgroundButton.dart';
import '../result/result_model.dart';

// 1. まずはAPIから受け取った生のJSONデータをMapに変換します
// (実際にはhttpライブラリなどで取得したレスポンスボディをjsonDecodeする)
final Map<String, dynamic> apiResponseJson = {
  "success": true,
  "result": {
    "isAgari": true,
    "yakuman": 0,
    "yaku": {"平和": "1飜", "門前清自摸和": "1飜", "立直": "1飜", "ドラ": "1飜"},
    "han": 4,
    "fu": 20,
    "ten": 5200,
    "name": "",
    "text": "(東場北家)自摸 20符4飜 5",
    "oya": [2600, 2600, 2600],
    "ko": [2600, 1300, 1300],
  },
  "error": false,
};

// 2. JSONをモデルオブジェクトに変換
final mahjongResult = ApiResponse.fromJson(apiResponseJson).result;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // helpyonとJonghelpyonテキストを横に並べるための Column
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/helpyon.png', height: 200),
                  const SizedBox(width: 16), // 画像とテキストの間にスペースを追加
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jong',
                        style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8), // テキストの間にスペースを追加
                      const Text(
                        'Helpyon',
                        style: TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // const Text(
                  //   'Jong\nHelpyon',
                  //   style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                  // ),
                ],
              ),

              // assets/button_calc_inactive.pngを背景にしたボタン
              ImageBackgroundButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    // ダイアログの外側をタップしても閉じないようにする
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      // 作成したResultDialogウィジェットを呼び出す
                      return ResultDialog(result: mahjongResult);
                    },
                  );
                },
                text: "",
                // TODO: 後で直す
                imagePath: "assets/button_calc.png",
              ),
              // const SizedBox(height: 32),
              // ElevatedButton.icon(
              //   icon: const Icon(Icons.camera_alt),
              //   label: const Text('ヘルパー画面へ'),
              //   style: ElevatedButton.styleFrom(
              //     minimumSize: const Size(200, 56),
              //     textStyle: const TextStyle(fontSize: 20),
              //   ),
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       MaterialPageRoute(
              //         builder: (context) => const AdvancedCameraScreen(),
              //       ),
              //     );
              //   },
              // ),
              // const SizedBox(height: 24),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     _DialogButton(
              //       icon: Icons.local_florist,
              //       label: 'ドラ入力',
              //       onTap: () => showDoraDialog(context),
              //     ),
              //     const SizedBox(width: 24),
              //     _DialogButton(
              //       icon: Icons.info_outline,
              //       label: '状況入力',
              //       onTap: () => showSituationDialog(context),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
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

void showSituationDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => SituationDialog());
}

class DoraDialog extends StatefulWidget {
  @override
  State<DoraDialog> createState() => _DoraDialogState();
}

class _DoraDialogState extends State<DoraDialog> {
  final tiles = [
    'Etc_Center',
    'Etc_East',
    'Etc_Hatsu',
    'Etc_North',
    'Etc_South',
    'Etc_West',
    'Etc_White',
    'Manzu1',
    'Manzu2',
    'Manzu3',
    'Manzu4',
    'Manzu5',
    'Manzu6',
    'Manzu7',
    'Manzu8',
    'Manzu9',
    'Pinzu1',
    'Pinzu2',
    'Pinzu3',
    'Pinzu4',
    'Pinzu5',
    'Pinzu6',
    'Pinzu7',
    'Pinzu8',
    'Pinzu9',
    'Sowzu1',
    'Sowzu2',
    'Sowzu3',
    'Sowzu4',
    'Sowzu5',
    'Sowzu6',
    'Sowzu7',
    'Sowzu8',
    'Sowzu9',
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
                  // TODO: 選択結果を保存する処理
                  Navigator.of(context).pop(selected.toList());
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text('🌸 完了 🌸', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SituationDialog extends StatefulWidget {
  @override
  State<SituationDialog> createState() => _SituationDialogState();
}

class _SituationDialogState extends State<SituationDialog> {
  bool isReach = false;
  bool isDealer = false;
  int honba = 0;
  bool isTsumo = true;
  // TODO: 14牌の情報入力欄

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Text('状況入力'),
      content: SizedBox(
        width: size.width * 0.85,
        height: 220,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1カラム目
              SizedBox(
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('リーチしている'),
                      value: isReach,
                      onChanged: (v) => setState(() => isReach = v),
                    ),
                    SwitchListTile(
                      title: const Text('親'),
                      value: isDealer,
                      onChanged: (v) => setState(() => isDealer = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // 2カラム目
              SizedBox(
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('本場: '),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => setState(
                            () => honba = (honba > 0) ? honba - 1 : 0,
                          ),
                        ),
                        Text('$honba'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setState(() => honba++),
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('自摸'),
                      value: isTsumo,
                      onChanged: (v) => setState(() => isTsumo = v),
                    ),
                  ],
                ),
              ),
              // ここに今後、14牌入力欄などを横に追加可能
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: ローカル保存処理
            Navigator.of(context).pop();
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
