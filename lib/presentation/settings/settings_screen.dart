// lib/presentation/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(inferenceModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('推論モード'),
            subtitle: Text(currentMode == 'local' ? '端末上 (高速)' : 'API (高精度)'),
          ),
          RadioListTile<String>(
            title: const Text('端末上 (高速)'),
            subtitle: const Text('ネットワーク不要で素早く動作します。'),
            value: 'local',
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(inferenceModeProvider.notifier).state = value;
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('API (高精度)'),
            subtitle: const Text('サーバーで処理するため高精度ですが、通信が必要です。'),
            value: 'api',
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(inferenceModeProvider.notifier).state = value;
              }
            },
          ),
        ],
      ),
    );
  }
}
