// lib/presentation/camera/camera_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/mahjong_models.dart'; // 変更: インポートパスを修正
import '../../domain/services/mahjong_logic_services.dart';
import '../settings/settings_screen.dart';
import './widgets/detection_pointer.dart';
import '../home/home_screen.dart'; // 追加: DoraDialog/SituationDialogのため

// UIで利用するためのProvider定義
final mahjongLogicServiceProvider = Provider((ref) => MahjongLogicService());

final mahjongGameStateProvider = StateProvider<MahjongGameState>((ref) {
  return MahjongGameState.empty();
});

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await ref.read(availableCamerasProvider.future);
    if (cameras.isEmpty) {
      print("No camera found");
      return;
    }
    _controller = CameraController(
      cameras[0], // 最初のカメラを使用
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
    if (!mounted) return;

    // 画像ストリームを開始
    _controller!.startImageStream(_processImage);
    setState(() {});
  }

  /// カメラストリームから画像を受け取り、推論パイプラインを実行する
  void _processImage(CameraImage image) {
    if (_isProcessing) return; // 処理中の場合はスキップ

    setState(() {
      _isProcessing = true;
    });

    // 非同期で推論を実行
    Future(() async {
      final inferenceRepo = ref.read(inferenceRepositoryProvider);
      final detections = await inferenceRepo.runInference(image);

      // 推論結果を麻雀ロジックで解釈
      final logicService = ref.read(mahjongLogicServiceProvider);
      final screenSize = MediaQuery.of(context).size; // 画面サイズを取得
      final newGameState = logicService.processDetections(
        detections,
        screenSize,
      );

      // UIスレッドで状態を更新
      if (mounted) {
        ref.read(mahjongGameStateProvider.notifier).state = newGameState;
      }
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = _controller;
    final gameState = ref.watch(mahjongGameStateProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: (cameraController == null || !cameraController.value.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                // カメラ映像（アスペクト比維持）
                Center(
                  child: AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: CameraPreview(cameraController),
                  ),
                ),
                // 牌認識オーバーレイ
                CustomPaint(
                  painter: DetectionPainter(
                    gameState: gameState,
                  ),
                ),
                // 透過ヘッダー（戻る・タイトル・設定）
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8, // ステータスバー重複回避
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '麻雀支援',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // 画面左下：どら入力ダイアログボタン
                Positioned(
                  left: 16,
                  bottom: 24,
                  child: FloatingActionButton(
                    heroTag: 'dora',
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: const Icon(Icons.local_florist, color: Colors.black),
                    onPressed: () {
                      showDoraDialog(context);
                    },
                  ),
                ),
                // 画面右下：状況入力ダイアログボタン
                Positioned(
                  right: 16,
                  bottom: 24,
                  child: FloatingActionButton(
                    heroTag: 'situation',
                    backgroundColor: Colors.white.withOpacity(0.85),
                    child: const Icon(Icons.info_outline, color: Colors.black),
                    onPressed: () {
                      showSituationDialog(context);
                    },
                  ),
                ),
                // 処理中インジケータ（デバッグ用）
                if (_isProcessing)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 60,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Processing...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

void showDoraDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => DoraDialog(),
  );
}

void showSituationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => SituationDialog(),
  );
}