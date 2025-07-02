// lib/presentation/camera/camera_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/mahjong_models.dart'; // 変更: インポートパスを修正
import '../../domain/services/mahjong_logic_services.dart';
import '../settings/settings_screen.dart';
import './widgets/detection_pointer.dart';

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
      appBar: AppBar(
        title: const Text('麻雀支援'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: (cameraController == null || !cameraController.value.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(cameraController),
                CustomPaint(
                  painter: DetectionPainter(
                    gameState: gameState,
                    // isProcessing: _isProcessing,
                  ),
                ),
                // 処理中インジケータ（デバッグ用）
                if (_isProcessing)
                  Positioned(
                    top: 10,
                    right: 10,
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
