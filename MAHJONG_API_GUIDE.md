# 麻雀 API 使用ガイド

この文書は test-api.com の麻雀 API の使用方法を説明します。

## ファイル構造

```
lib/
├── data/
│   ├── datasources/
│   │   └── mahjong_api_client.dart       # APIクライアント (HTTP通信)
│   ├── models/
│   │   ├── recommendation_response_model.dart  # 推奨牌応答モデル
│   │   └── score_calculation_response_model.dart  # 点数計算応答モデル
│   └── repositories/
│       └── mahjong_api_repository.dart   # APIリポジトリ
├── domain/
│   └── services/
│       └── mahjong_service.dart          # ビジネスロジックサービス
├── core/
│   └── providers.dart                    # Riverpodプロバイダー
└── utils/
    └── mahjong_api_example.dart          # 使用例
```

## 主要機能

### 1. 推奨牌 API

- 現在の牌情報を渡すと推奨する牌を返します。
- 文字列形式(`"112233456789m11s"`)またはリスト形式対応

### 2. 点数計算 API

- 現在の牌情報を渡すと点数と可能な役を計算して返します。
- 文字列形式(`"112233456789m11s"`)またはリスト形式対応
- オプション: `extra` (追加状態), `dora` (ドラ牌), `wind` (風情報) サポート

## 使用方法

### 1. プロバイダーを通じた使用 (推奨)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers.dart';

class MahjongScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mahjongService = ref.watch(mahjongServiceProvider);

    return ElevatedButton(
      onPressed: () async {
        try {
          // 文字列形式で推奨牌を取得
          final response = await mahjongService.getRecommendationFromString(
            tilesString: "112233456789m11s",
          );

          // オプション付き推奨牌を取得
          final responseWithOptions = await mahjongService.getRecommendationFromString(
            tilesString: "112233456789m11s",
            extra: "r", // リーチ状態
            dora: ["2m", "5s"], // ドラ牌
            wind: "14", // 風情報
          );

          // 結果処理
          print('推奨牌: ${response.recommend}');
          print('推奨牌表示名: ${response.recommendedTileDisplayName}');
        } catch (e) {
          print('API呼び出し失敗: $e');
        }
      },
      child: Text('推奨牌取得'),
    );
  }
}
```

### 2. 直接サービス使用

```dart
import 'package:http/http.dart' as http;
import 'data/datasources/mahjong_api_client.dart';
import 'data/repositories/mahjong_api_repository.dart';
import 'domain/services/mahjong_service.dart';

void main() async {
  // サービス初期化
  final httpClient = http.Client();
  final apiClient = MahjongApiClient(httpClient: httpClient);
  final repository = MahjongApiRepository(apiClient: apiClient);
  final service = MahjongService(repository: repository);

  try {
    // 推奨牌取得 (基本)
    final recommendation = await service.getRecommendationFromString(
      tilesString: "112233456789m11s",
    );

    // 推奨牌取得 (オプション付き)
    final recommendationWithOptions = await service.getRecommendationFromString(
      tilesString: "112233456789m11s",
      extra: "r", // リーチ状態
      dora: ["3m", "7s"], // ドラ牌
      wind: "14", // 風情報
    );

    // 点数計算 (基本)
    final scoreResult = await service.calculateScoreFromString(
      tilesString: "112233456789m11s",
    );

    // 点数計算 (オプション付き)
    final scoreWithOptions = await service.calculateScoreFromString(
      tilesString: "112233456789m11s",
      extra: "r", // リーチ状態
      dora: ["2m", "5s"], // ドラ牌
      wind: "14", // 風情報
    );

    print('推奨牌: ${recommendation.recommend}');
    print('現在点数: ${scoreResult.result.ten}');

  } catch (e) {
    print('エラー: $e');
  } finally {
    // リソース清理
    service.dispose();
  }
}
```

## 牌文字列形式

麻雀牌は以下のような文字列形式で表現されます：

- `m`: 萬子牌 (1m, 2m, ..., 9m)
- `p`: 筒子牌 (1p, 2p, ..., 9p)
- `s`: 索子牌 (1s, 2s, ..., 9s)
- `z`: 字牌 (1z~7z: 東南西北白發中)

### 例

- `"112233456789m"`: 萬子牌 1,1,2,2,3,3,4,5,6,7,8,9
- `"112233456789m11s"`: 萬子牌 + 索子牌 1,1
- `"123m456p789s1122z"`: 萬子 123 + 筒子 456 + 索子 789 + 東東 + 南南

## API リクエスト/レスポンス 形式

### 推奨牌 API リクエスト

**基本リクエスト:**

```json
{
  "hand": "112233456789m11s"
}
```

### 点数計算 API リクエスト

**基本リクエスト:**

```json
{
  "hand": "23m456678p345s33z1m",
  "extra": "r",
  "dora": ["2m", "7s"],
  "wind": "14"
}
```

## API 応答形式

### 推奨牌応答

```json
{
  "recommend": "2s"
}
```

### 点数計算応答

```json
{
  "success": true,
  "result": {
    "isAgari": true,
    "yakuman": 0,
    "yaku": { "一気通貫": "2飜", "一盃口": "1飜", "門前清自摸和": "1飜" },
    "han": 4,
    "fu": 30,
    "ten": 7900,
    "name": "",
    "text": "(東場南家)自摸 30符4飜 7900点(3900,2000)",
    "oya": [3900, 3900, 3900],
    "ko": [3900, 2000, 2000],
    "error": false
  },
  "error": null,
  "input": {
    "originalHand": "112233456789m11s",
    "processedHand": "112233456789m11s",
    "options": {
      "dora": [],
      "extra": null,
      "wind": null,
      "disableWyakuman": false,
      "disableKuitan": false,
      "disableAka": false,
      "enableLocalYaku": [],
      "disableYaku": []
    }
  }
}
```

## エラー処理

API 呼び出し時に以下のようなエラーが発生する可能性があります：

- `ArgumentError`: 不正な入力 (空文字列、不正な形式など)
- `MahjongApiException`: API 呼び出し失敗 (ネットワークエラー、サーバーエラーなど)

```dart
try {
  final result = await service.getRecommendationFromString(
    tilesString: tilesString,
  );
} on ArgumentError catch (e) {
  print('入力エラー: $e');
} on MahjongApiException catch (e) {
  print('APIエラー: ${e.message} (ステータスコード: ${e.statusCode})');
} catch (e) {
  print('不明なエラー: $e');
}
```

## 依存関係

プロジェクトに以下のパッケージが必要です：

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  http: ^1.2.1
```

これらのパッケージは既に`pubspec.yaml`に追加されています。
