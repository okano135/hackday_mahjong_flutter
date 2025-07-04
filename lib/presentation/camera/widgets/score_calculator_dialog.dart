import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mahjong_app/dora_state.dart';

import '../../../data/datasources/mahjong_api_client.dart';
// import 'package:mahjong_app/hand_state.dart'; // handProviderは不要になるためコメントアウトまたは削除

import 'image_background_button.dart';
import 'result_mapper.dart';
import 'result_screen.dart';

// --- Enumやヘルパー関数 (変更なし) ---
enum RiichiState { declared, notDeclared }

enum WinningMethod { tsumo, ron }

enum Wind { east, south, west, north }

String _getDisplayText(dynamic enumValue) {
  // (中身は変更なし)
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

String getTileImagePath(String tileName) {
  return 'assets/pis/$tileName.png';
}

/// 点数計算ダイアログ本体
class ScoreCalculatorDialog extends ConsumerStatefulWidget {
  // --- 変更点 1 ---
  // 手牌のリストをコンストラクタで受け取る
  final List<String> hand;

  const ScoreCalculatorDialog({
    super.key,
    required this.hand, // requiredキーワードで必須引数にする
  });

  @override
  ConsumerState<ScoreCalculatorDialog> createState() =>
      _ScoreCalculatorDialogState();
}

class _ScoreCalculatorDialogState extends ConsumerState<ScoreCalculatorDialog> {
  // ダイアログ内のローカルな選択状態 (変更なし)
  RiichiState _riichi = RiichiState.notDeclared;
  WinningMethod _winningMethod = WinningMethod.tsumo;
  Wind _playerWind = Wind.east;
  Wind _prevalentWind = Wind.east;
  String? _selectedWinningTile;

  @override
  Widget build(BuildContext context) {
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
                    // (中略: 左側のタイトル部分は変更なし)
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
                    // 右側の選択肢部分
                    Expanded( // <--- 💡 これを追加！
                    child:
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
                        // --- 変更点 3 ---
                        // widget.hand を使ってアガリ牌セレクターを構築する
                        _buildWinningTileSelector(widget.hand),
                      ],
                    ),),
                  ],
                ),
                const SizedBox(height: 32),
                Center(
                  child: ImageBackgroundButton(
                    onPressed: _calculateAndSendScore,
                    text: "",
                    imagePath: "assets/button_calc.png",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoraSection(List<String> dora) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
        OutlinedButton(
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
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

  Widget _buildSectionTitle(String title) {
    // (中身は変更なし)
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

  Widget _buildToggleGroup<T>({
    required List<T> options,
    required T selectedValue,
    required ValueChanged<T> onSelected,
  }) {
    // (中身は変更なし)
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: options.map((option) {
        final isSelected = option == selectedValue;
        final iconWidget = _getToggleIcon(option, isSelected);
        return ChoiceChip(
          avatar: iconWidget,
          label: Text(_getDisplayText(option)),
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
    // (中身は変更なし)
    String? assetName;
    if (isSelected) {
      assetName = "radioButton_pink.png";
    } else {
      assetName = "radioButton_default.png";
    }
    if (assetName != null) {
      return Image.asset('assets/$assetName', width: 20, height: 20);
    }
    return const SizedBox.shrink();
  }

  Widget _buildWinningTileSelector(List<String> hand) {
    // (このメソッドの内部実装は変更なし)
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

  /// Flutterの牌名をAPI仕様の形式に変換するヘルパー関数
  String _convertTileToApiFormat(String tileName) {
    if (tileName.startsWith('Etc_')) {
      switch (tileName) {
        case 'Etc_East':
          return '1z';
        case 'Etc_South':
          return '2z';
        case 'Etc_West':
          return '3z';
        case 'Etc_North':
          return '4z';
        case 'Etc_White':
          return '5z';
        case 'Etc_Hatsu':
          return '6z';
        case 'Etc_Center':
          return '7z';
        default:
          return '';
      }
    } else {
      final number = tileName.substring(tileName.length - 1);
      if (tileName.startsWith('Manzu')) return '${number}m';
      if (tileName.startsWith('Pinzu')) return '${number}p';
      if (tileName.startsWith('Sowzu')) return '${number}s';
    }
    return '';
  }

  /// 手牌リストからAPIの 'hand' パラメータ文字列を構築する
  String _buildHandParameter(
    List<String> fullHand,
    String winningTile,
    WinningMethod winningMethod,
  ) {
    // 手牌リストからアガリ牌を1枚取り除く
    final handWithoutWinningTile = List<String>.from(fullHand);
    handWithoutWinningTile.remove(winningTile);

    // 各牌をAPI形式に変換
    final apiTiles = handWithoutWinningTile
        .map(_convertTileToApiFormat)
        .toList();
    final apiWinningTile = _convertTileToApiFormat(winningTile);

    // 種類ごとに分類してソート
    final man = apiTiles.where((t) => t.endsWith('m')).map((t) => t[0]).toList()
      ..sort();
    final pin = apiTiles.where((t) => t.endsWith('p')).map((t) => t[0]).toList()
      ..sort();
    final sou = apiTiles.where((t) => t.endsWith('s')).map((t) => t[0]).toList()
      ..sort();
    final honors =
        apiTiles.where((t) => t.endsWith('z')).map((t) => t[0]).toList()
          ..sort();

    // API仕様の文字列に結合
    final handBuilder = StringBuffer();
    if (man.isNotEmpty) handBuilder.write('${man.join()}m');
    if (pin.isNotEmpty) handBuilder.write('${pin.join()}p');
    if (sou.isNotEmpty) handBuilder.write('${sou.join()}s');
    if (honors.isNotEmpty) handBuilder.write('${honors.join()}z');

    // 和了牌を追加 (ロンの場合は '+' を付ける)
    if (winningMethod == WinningMethod.ron) {
      handBuilder.write('+');
    }
    handBuilder.write(apiWinningTile);

    // TODO: 副露(鳴き)がある場合はここに結合ロジックを追加

    return handBuilder.toString();
  }

  /// 点数計算リクエストをサーバーに送信する
  // _ScoreCalculatorDialogState内に配置
  Future<void> _calculateAndSendScore() async {
    if (_selectedWinningTile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('アガリ牌を選択してください。')));
      return;
    }

    // APIリクエストの準備 (前回と同じ)
    final apiHand = _buildHandParameter(
      widget.hand,
      _selectedWinningTile!,
      _winningMethod,
    );
    String apiExtra = (_riichi == RiichiState.declared) ? 'r' : '';
    final apiDora = ref
        .read(doraProvider)
        .map(_convertTileToApiFormat)
        .toList();
    final prevalentWindMap = {Wind.east: '1', Wind.south: '2'};
    final playerWindMap = {
      Wind.east: '1',
      Wind.south: '2',
      Wind.west: '3',
      Wind.north: '4',
    };
    final apiWind =
        '${prevalentWindMap[_prevalentWind]}${playerWindMap[_playerWind]}';

    try {
      // 1. ProviderからMahjongApiClientのインスタンスを取得
      final apiClient = ref.read(mahjongApiClientProvider);

      // 2. APIクライアントのメソッドを呼び出し、レスポンスモデルを直接受け取る
      final responseModel = await apiClient.calculateScoreFromString(
        tilesString: apiHand,
        extra: apiExtra.isNotEmpty ? apiExtra : null,
        dora: apiDora,
        wind: apiWind,
      );

      if (!mounted) return;

      // 3. レスポンスモデルを元に成功判定とダイアログ表示
      // ※ScoreCalculationResponseModel と MahjongResult のプロパティ名は
      //   実際のモデル定義に合わせてください。
      if (responseModel.success && responseModel.result.isAgari) {
        // 現在の計算ダイアログを閉じる
        Navigator.of(context).pop();

        // 新しい結果表示ダイアログを表示する
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            // ResultDialogに渡す result の型がAPIクライアントのモデルと一致していることを確認
            return ResultDialog(result: responseModel.result.toMahjongResult());
          },
        );
      } else {
        // 和了形ではない、またはAPI側でエラーがあった場合
        final errorMessage =
            responseModel.error?.isNotEmpty ==
                true // null でなく、かつ空でない場合
            ? responseModel.error! // ここで null ではないことを保証
            : responseModel.result.text.isNotEmpty == true
            ? responseModel.result.text
            : '計算できませんでした。';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } on MahjongApiException catch (e) {
      // 4. MahjongApiClientからスローされた例外をキャッチ
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('APIエラー: ${e.message}')));
    } catch (e) {
      // 5. その他の予期せぬ例外をキャッチ
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('予期せぬエラーが発生しました: $e')));
    }

    // final requestBody = {
    //   'hand': apiHand,
    //   'extra': apiExtra,
    //   'dora': apiDora,
    //   'wind': apiWind,
    // };

    // const apiUrl =
    //     'https://54.64.215.47/api/v1/score'; // TODO: 実際のAPIエンドポイントに置き換える
    // try {
    //   print('Sending request to $apiUrl with body: $requestBody');
    //   final response = await http.post(
    //     Uri.parse(apiUrl),
    //     headers: {'Content-Type': 'application/json; charset=UTF-8'},
    //     body: jsonEncode(requestBody),
    //   );

    //   // 非同期処理後にcontextを安全に使うためのチェック
    //   if (!mounted) return;

    //   if (response.statusCode == 200) {
    //     // 1. レスポンスボディを日本語が文字化けしないようにデコード
    //     final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

    //     // 2. JSONからApiResponseオブジェクトを生成
    //     final apiResponse = ApiResponse.fromJson(decodedBody);

    //     // 3. APIの処理が成功し、かつ和了形であるかチェック
    //     if (apiResponse.success && apiResponse.result.isAgari) {
    //       // 4. 現在の計算ダイアログを閉じる
    //       Navigator.of(context).pop();

    //       // 5. 新しい結果表示ダイアログを表示する
    //       showDialog(
    //         context: context,
    //         builder: (BuildContext dialogContext) {
    //           // 結果データをResultDialogに渡す
    //           return ResultDialog(result: apiResponse.result);
    //         },
    //       );
    //     } else {
    //       // 和了形ではない、またはAPI側でエラーがあった場合
    //       final errorMessage = apiResponse.result.text.isNotEmpty
    //           ? apiResponse.result.text
    //           : '計算できませんでした。';
    //       ScaffoldMessenger.of(
    //         context,
    //       ).showSnackBar(SnackBar(content: Text(errorMessage)));
    //     }
    //   } else {
    //     // HTTPステータスコードが200以外の場合のエラーハンドリング
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text('サーバーエラーが発生しました: ${response.statusCode}')),
    //     );
    //   }
    // } catch (e) {
    //   // 通信エラーなどの例外処理
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('通信エラー: $e')));
    // }
  }
}

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

/// ドラ選択セクション全体を表すウィジェット
class DoraSection extends ConsumerWidget {
  const DoraSection({Key? key}) : super(key: key);

  /// ドラのリストから牌ごとの個数を集計するヘルパーメソッド
  Map<String, int> _getDoraCounts(List<String> dora) {
    final counts = <String, int>{};
    for (final tile in dora) {
      counts[tile] = (counts[tile] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providerを監視してドラのリストを取得
    final dora = ref.watch(doraProvider);
    final doraCounts = _getDoraCounts(dora);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 選択済みドラの表示エリア
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: dora.isEmpty
              ? const Text(
                  "下のカルーセルからドラを選択",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                )
              : Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: doraCounts.keys.map((tileName) {
                    final count = doraCounts[tileName]!;
                    return Tooltip(
                      message: 'タップして削除',
                      child: GestureDetector(
                        onTap: () => ref
                            .read(doraProvider.notifier)
                            .removeDora(tileName),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(getTileImagePath(tileName), height: 40),
                            // 個数表示バッジ
                            if (count > 1)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    count.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 16),

        // 2. ドラ選択カルーセル
        SizedBox(
          height: 50, // カルーセルの高さ
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allTiles.length,
            itemBuilder: (context, index) {
              final tileName = allTiles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Tooltip(
                  message: 'タップして追加',
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(doraProvider.notifier).addDora(tileName),
                    child: Image.asset(getTileImagePath(tileName), height: 40),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
