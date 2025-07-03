// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/yolo_streaming_config.dart';
import 'package:ultralytics_yolo/yolo_task.dart';
import 'package:ultralytics_yolo/yolo_view.dart';
import 'dart:typed_data';

import '../../widgets/dora_effetct.dart'; // ドラのきらめきエフェクトを表示するWidget


class AdvancedCameraScreen extends StatefulWidget {
  @override
  State<AdvancedCameraScreen> createState() => _AdvancedCameraScreenState();
}

class _AdvancedCameraScreenState extends State<AdvancedCameraScreen> {
  List<dynamic> _currentDetections = [];
  Size _viewSize = Size.zero;

  @override
  Widget build(BuildContext context) {
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

                  // Update detections for overlay
                  setState(() {
                    _currentDetections = detections;
                  });

                  // Process complete frame data
                  processFrameData(detections, originalImage);
                },
              ),
              ..._buildDetectionOverlays(),
              
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

      if (className == 'Manzu4') {
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
            child: DoraEffect(), // 後で実装するきらめきエフェクトのWidget
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