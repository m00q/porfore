# PokéLab Red-Black Tree

`red_black_tree.dart`는 Flutter에 의존하지 않는 정수 집합입니다. 중복 값은
`duplicateFound`로 보고하고 기존 트리를 유지합니다. NIL 자식은 검정이며,
외부 스냅샷에서는 `null` 링크로 표현됩니다.

```dart
import 'package:porfore/pokelab/red_black_tree.dart';

final tree = RedBlackTree();
final operation = tree.insert(25); // 아직 비교·삽입하지 않음
final initial = operation.initialSnapshot;
final history = <TreeStep>[];

// Next 버튼 또는 자동 진행 타이머에서 한 번씩 호출합니다.
final step = operation.nextStep();
if (step != null) {
  history.add(step);
  // step.snapshot으로 표시하고 애니메이션 완료 후 다음 단계를 요청합니다.
}
```

- `insert`, `search`, `delete`는 단일 사용 `TreeOperation`을 만듭니다.
  `nextStep()`은 한 이벤트까지만 실행하며, 내부 `sync*`가 다음 요청까지 멈춥니다.
- 비교, 이동, 삽입 위치, 부모·삼촌 색 확인, 개별 노드 색 변경, 회전,
  후계자 탐색, 교체, 삭제, Double Black과 형제·조카 확인을 별도로 전달합니다.
  포인터 변경 여러 개가 필요한 회전·교체는 하나의 구조 변경 단계입니다.
- Step의 `nodeId`는 검사 대상/회전 축, `relatedNodeId`는 이동 대상/삼촌/형제/
  교체 노드/회전으로 올라온 노드입니다. 비교에는 `targetValue`, `comparison`과
  스냅샷 속 현재 노드 값이 있습니다. `description`은 기본 한국어 설명이며,
  다국어 UI는 `type`과 데이터로 별도 설명을 구성할 수 있습니다.
- 삭제는 후계자의 ID를 유지한 채 위치를 옮깁니다. `remove.nodeId`는 삭제 요청
  대상이고, `checkRemovedColor.oldColor`는 검정 높이에 영향을 주는 제거된 자리의
  원래 색입니다. 이미 분리된 노드는 현재 스냅샷에 없을 수 있으므로 제거 애니메이션은
  이전 스냅샷도 사용합니다. NIL Double Black 위치는 `parentId`, `isLeftChild`로
  식별합니다.
- 스냅샷은 읽기 전용이며 실제 트리 노드를 노출하지 않습니다. 균형 복구 도중에는
  루트 색, 연속 빨강, 검정 높이 규칙이 일시적으로 깨질 수 있습니다. 완료 시 모든
  Red-Black Tree 규칙을 만족합니다.
- `operationComplete`는 성공/중복/미발견을 포함한 마지막 이벤트입니다.
  이 이벤트를 반환하는 즉시 잠금이 해제되며 이후 `nextStep()`은 `null`입니다.
  탐색 완료는 별도 `searchComplete`로 제공하고 삭제의 대상 탐색에서도 발생합니다.
- 진행 중에는 다른 연산을 생성할 수 없습니다(`StateError`). 일시 정지는 단순히
  다음 Step을 요청하지 않는 것입니다. `cancel()`은 초기 스냅샷으로 되돌리고 잠금을
  해제합니다. 취소 시 소비자가 `initialSnapshot`을 표시해야 하며, 완료된 연산의
  취소는 아무 동작도 하지 않습니다.
- 이전 단계/전체 재생은 `initialSnapshot`과 수신한 Step 목록을 표시하면 됩니다.
  알고리즘 재실행이나 실시간 트리의 되감기를 의미하지 않습니다. 기록 보관 여부와
  재생 속도는 소비자가 결정합니다.

스냅샷은 매 Step마다 현재 연결된 노드 전체를 복사합니다. 기본 트리 연산은
O(log n)이지만, 이 시각화 구현의 시간·저장 비용은 Step 수 × O(n)입니다.
대규모 트리를 다룰 때는 차이 기반 기록을 별도로 고려할 수 있습니다.

검증: `flutter test test/red_black_tree_test.dart`
