# 마작 API 사용 가이드

이 문서는 test-api.com의 마작 API를 사용하는 방법을 설명합니다.

## 파일 구조

```
lib/
├── data/
│   ├── datasources/
│   │   └── mahjong_api_client.dart       # API 클라이언트 (HTTP 통신)
│   ├── models/
│   │   ├── mahjong_tile_model.dart       # 마작 패 모델
│   │   ├── recommendation_response_model.dart  # 추천 패 응답 모델
│   │   └── score_calculation_response_model.dart  # 점수 계산 응답 모델
│   └── repositories/
│       └── mahjong_api_repository.dart   # API 레포지토리
├── domain/
│   └── services/
│       └── mahjong_service.dart          # 비즈니스 로직 서비스
├── core/
│   └── providers.dart                    # Riverpod 프로바이더들
└── utils/
    └── mahjong_api_example.dart          # 사용 예시
```

## 주요 기능

### 1. 추천 패 API

- 현재 패 정보를 전달하면 추천하는 패를 반환합니다.
- 문자열 형식(`"112233456789m11s"`) 또는 리스트 형식 지원

### 2. 점수 계산 API

- 현재 패 정보를 전달하면 점수와 가능한 역을 계산해서 반환합니다.
- 문자열 형식(`"112233456789m11s"`) 또는 리스트 형식 지원

## 사용 방법

### 1. 프로바이더를 통한 사용 (권장)

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
          // 문자열 형식으로 추천 패 가져오기
          final response = await mahjongService.getRecommendationFromString(
            tilesString: "112233456789m11s",
          );

          // 결과 처리
          for (final recommendedTile in response.recommendedTiles) {
            print('추천 패: ${recommendedTile.tile.displayName}');
            print('이유: ${recommendedTile.reason}');
            print('점수: ${recommendedTile.score}');
          }
        } catch (e) {
          print('API 호출 실패: $e');
        }
      },
      child: Text('추천 패 가져오기'),
    );
  }
}
```

### 2. 직접 서비스 사용

```dart
import 'package:http/http.dart' as http;
import 'data/datasources/mahjong_api_client.dart';
import 'data/repositories/mahjong_api_repository.dart';
import 'domain/services/mahjong_service.dart';

void main() async {
  // 서비스 초기화
  final httpClient = http.Client();
  final apiClient = MahjongApiClient(httpClient: httpClient);
  final repository = MahjongApiRepository(apiClient: apiClient);
  final service = MahjongService(repository: repository);

  try {
    // 추천 패 가져오기
    final recommendation = await service.getRecommendationFromString(
      tilesString: "112233456789m11s",
    );

    // 점수 계산하기
    final scoreResult = await service.calculateScoreFromString(
      tilesString: "112233456789m11s",
    );

    print('추천 패 개수: ${recommendation.recommendedTiles.length}');
    print('현재 점수: ${scoreResult.currentScore.finalScore}');

  } catch (e) {
    print('오류: $e');
  } finally {
    // 리소스 정리
    service.dispose();
  }
}
```

## 패 문자열 형식

마작 패는 다음과 같은 문자열 형식으로 표현됩니다:

- `m`: 만수패 (1m, 2m, ..., 9m)
- `p`: 통수패 (1p, 2p, ..., 9p)
- `s`: 삭수패 (1s, 2s, ..., 9s)
- `z`: 자패 (1z~7z: 동남서북백발중)

### 예시

- `"112233456789m"`: 만수패 1,1,2,2,3,3,4,5,6,7,8,9
- `"112233456789m11s"`: 만수패 + 삭수패 1,1
- `"123m456p789s1122z"`: 만수 123 + 통수 456 + 삭수 789 + 동동 + 남남

## API 응답 형식

### 추천 패 응답

```json
{
  "success": true,
  "message": "성공",
  "recommendedTiles": [
    {
      "tile": {
        "id": "man4",
        "displayName": "四萬",
        "isDora": false,
        "isCandidate": true
      },
      "priority": 1,
      "reason": "텐파이 달성",
      "score": 0.85
    }
  ]
}
```

### 점수 계산 응답

```json
{
  "success": true,
  "message": "성공",
  "currentScore": {
    "baseScore": 1000,
    "han": 1,
    "fu": 30,
    "finalScore": 1000,
    "yakuName": "리치"
  },
  "possibleYaku": [
    {
      "name": "핑후",
      "han": 1,
      "description": "순자만으로 구성된 역",
      "probability": 0.7
    }
  ]
}
```

## 에러 처리

API 호출 시 다음과 같은 에러가 발생할 수 있습니다:

- `ArgumentError`: 잘못된 입력 (빈 문자열, 잘못된 형식 등)
- `MahjongApiException`: API 호출 실패 (네트워크 오류, 서버 오류 등)

```dart
try {
  final result = await service.getRecommendationFromString(
    tilesString: tilesString,
  );
} on ArgumentError catch (e) {
  print('입력 오류: $e');
} on MahjongApiException catch (e) {
  print('API 오류: ${e.message} (상태코드: ${e.statusCode})');
} catch (e) {
  print('알 수 없는 오류: $e');
}
```

## 의존성

프로젝트에 다음 패키지들이 필요합니다:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  http: ^1.2.1
```

이 패키지들은 이미 `pubspec.yaml`에 추가되어 있습니다.
