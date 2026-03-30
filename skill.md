# iOS 앱 기반 게임 개발 스킬 가이드

이 문서는 SwiftUI 기반 iOS 게임 앱 개발에 필요한 기술적 지식과 베스트 프랙티스를 정리한다.

---

## 1. SwiftUI 성능 최적화

### View 렌더링

- **View body는 가볍게 유지**: body 내에서 필터링, 네트워크 요청, 이미지 처리 등 무거운 작업 금지. ViewModel이나 백그라운드 태스크로 이동
- **작은 subview로 분리**: 독립적인 작은 뷰로 분리하면 invalidation 범위가 줄어들어 불필요한 리렌더 방지
- **안정적인 id 부여**: 리스트/컬렉션에서 항목별로 고유하고 안정적인 id를 사용. 불안정한 id는 불필요한 재빌드/애니메이션 유발
- **Lazy 컨테이너 활용**: 많은 항목을 표시할 때 `LazyVStack`, `LazyHStack`, `LazyVGrid` 사용 — 화면에 보이는 항목만 렌더링

### GPU 부하 관리

- `.shadow`, `.blur`, `.opacity`, `.mask`는 GPU 부하가 큼 → 유사한 효과는 `.overlay` 하나로 통합
- 자주 업데이트되는 요소(타이머 등)에는 애니메이션 비활성화
- 레이아웃 변경과 opacity 변경을 동시에 애니메이션하지 않기

### 프로파일링

- Xcode Instruments로 정기적으로 프로파일링
- WWDC 2025 Instruments 26의 SwiftUI instrument — Cause & Effect Graph로 업데이트 관계 시각화
- 히치(hitch), 행(hang), 프레임 드롭을 측정하여 병목 조기 발견

---

## 2. Shape/Path 코드 드로잉

### Path vs Shape

| | Path | Shape |
|---|---|---|
| 좌표 | 절대 좌표 | 주어진 rect 기준 상대 좌표 |
| 재사용 | 특정 용도 1회성 | 파라미터를 받아 유연하게 재사용 |
| 권장 | 단순 고정 그래픽 | **카피바라 부위처럼 유전자 파라미터로 변형되는 요소** |

### 성능 전략

| 접근법 | 적합한 상황 |
|--------|-----------|
| Path / Shape (기본 Core Animation) | 단순한 소수의 도형 |
| `drawingGroup()` (Metal 렌더링) | 그라데이션/도형이 많아 성능 저하 시 |
| `Canvas` | 프레임마다 많은 요소를 동적으로 그려야 할 때 |

- **기본은 Shape/Path로 시작**, 성능 문제 발생 시에만 `drawingGroup()` 적용
- `drawingGroup()`은 오프스크린 Metal 렌더링 → 단순 그래픽에서는 오히려 느려질 수 있음
- 파티클 시스템처럼 많은 요소를 매 프레임 그릴 때는 `Canvas` 고려

### 드로잉 팁

- 좌표는 `CGRect`의 `minX`, `midX`, `maxX`, `minY`, `midY`, `maxY` 활용하여 상대적으로 계산
- `StrokeStyle`로 선 연결(line join)과 끝처리(line cap) 제어
- `closeSubpath()` 호출을 잊지 않기 — 아티팩트 방지

---

## 3. 제스처 처리

### 기본 제스처

| 제스처 | 반환 데이터 | 용도 (이 앱에서) |
|--------|-----------|-----------------|
| `TapGesture` | Void (또는 CGPoint) | 먹이주기 탭, 놀기 더블탭 |
| `LongPressGesture` | Bool | 꾹 누르기 → 졸리기 |
| `DragGesture` | 위치, 변위, 시간, 예측 끝점 | 쓰다듬기, 물웅덩이로 드래그 |

### 제스처 조합

| 방식 | 설명 | 사용 예 |
|------|------|---------|
| `.simultaneousGesture()` | 두 제스처를 동시에 인식 | 드래그 중 탭 감지 |
| `.highPriorityGesture()` | 한 제스처가 우선 | 카피바라 영역 탭이 배경 탭보다 우선 |
| `.exclusively(before:)` | 둘 중 하나만 인식 | 탭 vs 롱프레스 분기 |
| `.sequenced(before:)` | 순차 실행 | 롱프레스 후 드래그 (물웅덩이 이동) |

### 주의사항

- SwiftUI 제스처는 단일 손가락만 지원 (멀티터치 필요 시 UIKit 브릿지)
- `TapGesture`와 `LongPressGesture`는 조건 충족 시 자동 종료 — 지속적 추적 불가
- 복잡한 제스처 조합 시 우선순위 충돌 테스트 필수

---

## 4. SwiftData 데이터 관리

### 성능 베스트 프랙티스

- **대용량 프로퍼티는 external storage로**: `@Query`는 모든 프로퍼티를 메모리에 로드 → 큰 데이터는 `.externalStorage` 사용
- **Predicate 최적화**: Swift에서 필터링하지 말고 predicate에서 필터링. 가장 제한적인 조건을 먼저 배치
- **Fetch limit 사용**: 필요한 만큼만 가져오기
- **관계 프리페치**: `relationshipKeyPathsForPrefetching`으로 필요한 관계를 한 번에 로드
- **save() 호출 불필요**: SwiftData는 자동 저장 — 네비게이션/백그라운드 진입 시 자동 persist

### 주의사항

- `ModelContext`와 모델 객체는 **Sendable이 아님** → actor 경계를 넘길 때는 `ModelContainer`를 전달하고 로컬 context 생성
- `@Model`이라도 내부적으로는 SQLite 제약을 받음 — 일반 Swift 객체처럼 자유롭지 않음
- 복잡한 타입(예: `CapybaraGenes`)은 Codable로 직렬화하여 단일 컬럼에 저장
- iOS 17+ 전용 — 이 프로젝트는 iOS 16+ 타겟이므로 **iOS 17 미만 폴백 고려 필요**

---

## 5. 햅틱 & 사운드 디자인

### Apple의 3대 원칙 (WWDC)

1. **인과성 (Causality)**: 피드백이 무엇에 의해 발생했는지 명확해야 함
2. **조화 (Harmony)**: 시각, 청각, 촉각이 일관되어야 함. 작은 동작은 가볍게, 큰 동작은 무겁게
3. **유용성 (Utility)**: 피드백이 앱 경험에 명확한 가치를 제공해야 함

### 햅틱 API 선택

| API | 용도 |
|-----|------|
| `UIImpactFeedbackGenerator` (.light, .medium, .heavy) | 간단한 충격 피드백 |
| `UISelectionFeedbackGenerator` | 선택 변경 |
| `UINotificationFeedbackGenerator` (.success, .warning, .error) | 결과 알림 |
| `CHHapticEngine` (Core Haptics) | 복잡한 커스텀 패턴 |

### 구현 팁

- **`prepare()` 호출 필수**: Taptic Engine을 미리 준비해야 지연 최소화
- **AVAudioSession 충돌 주의**: 오디오 녹음/재생 중 햅틱이 실패할 수 있음
- **멀티모달 동기화**: 시각 + 효과음 + 햅틱 사이에 레이턴시가 있으면 몰입감 깨짐 → 동시 트리거
- **효과음은 짧고 정확하게**: 속도/강도에 따라 amplitude 조절

### 접근성

- 햅틱 설정 옵션 제공: On / Minimal / Off
- 모든 햅틱/사운드 호출을 중앙 매니저에서 관리
- 실제 기기에서 테스트 필수 (시뮬레이터는 햅틱 미지원)

---

## 6. 애니메이션

### SwiftUI 애니메이션 기본

```swift
// 암시적 애니메이션
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: someState)

// 명시적 애니메이션
withAnimation(.easeInOut(duration: 0.3)) {
    someState = newValue
}
```

### 게임에서의 애니메이션 팁

- **스프링 애니메이션** 적극 활용 — 자연스러운 물리 느낌 (점프, 튕김)
- **`animatableData`** 프로토콜로 Shape의 커스텀 애니메이션 구현 (표정 변화, 귀 각도 등)
- 자주 업데이트되는 값에 애니메이션을 걸면 프레임 드롭 → 선별적 적용
- 큰 뷰 계층 전체에 애니메이션 금지 → 대상 뷰만 특정하여 적용
- `Transaction`으로 애니메이션 비활성화: `var transaction = Transaction(); transaction.disablesAnimations = true`

### 파티클 시스템

- 소수의 파티클(하트 5~10개)은 SwiftUI View로 충분
- 대량 파티클이 필요하면 `Canvas` 또는 `TimelineView` + `Canvas` 조합
- `TimelineView(.animation)` — 매 프레임마다 뷰 업데이트 트리거

---

## 7. 접근성 (Accessibility)

### VoiceOver

- **모든 상호작용 요소에 `accessibilityLabel` 부여**: "카피바라 모찌, 호감도 75%"
- **`accessibilityHint`로 동작 설명**: "두 번 탭하면 놀아줍니다"
- **장식적 요소는 `.accessibilityHidden(true)`**: 파티클, 배경 도형 등
- **관련 요소 그룹화**: `accessibilityElement(children: .combine)`
- **동적 변화 알림**: `UIAccessibility.post(notification: .announcement, argument: "모찌가 기뻐합니다")`

### Dynamic Type

- 시스템 폰트 + `.font(.body)` 등 시맨틱 스타일 사용
- 레이아웃이 다양한 텍스트 크기에서 깨지지 않도록 유연하게 구성
- Xcode Preview에서 여러 텍스트 사이즈로 테스트

### 색상 & 시각

- 시스템 색상 (`.primary`, `.secondary`) 우선 사용
- 정보를 색상만으로 전달하지 않기 (형태, 텍스트 병행)
- 다크 모드 지원 — Asset Catalog에서 Color Set으로 관리

---

## 8. 프로젝트 구성 & 빌드

### Xcode 프로젝트 설정

- Deployment Target: iOS 17.0
- Swift Language Version: 5.9+
- Build Configuration: Debug / Release 분리
- 시뮬레이터 + 실제 기기 양쪽에서 테스트

### 디바이스 대응

- iPhone SE (4.7") ~ iPhone 16 Pro Max (6.9") 레이아웃 대응
- `GeometryReader`로 카피바라 렌더링 영역을 디바이스에 맞게 스케일
- Safe Area 준수
- 가로 모드는 지원하지 않음 (세로 고정)

### 테스트 전략

- Unit Test: 유전자 시스템 (`random()`, `breed()`), 상태 변경 로직
- UI Test: 분양 흐름, 터치 상호작용
- Preview: 다양한 유전자 조합으로 카피바라 외형 검증
- 실제 기기: 햅틱, 사운드, 제스처 반응성

---

## 참고 자료

### Apple 공식
- [SwiftUI Performance](https://developer.apple.com/documentation/Xcode/understanding-and-improving-swiftui-performance)
- [Drawing Paths and Shapes](https://developer.apple.com/tutorials/swiftui/drawing-paths-and-shapes)
- [Composing SwiftUI Gestures](https://developer.apple.com/documentation/swiftui/composing-swiftui-gestures)
- [Playing Haptics (HIG)](https://developer.apple.com/design/human-interface-guidelines/patterns/playing-haptics/)
- [Designing Audio-Haptic Experiences (WWDC19)](https://developer.apple.com/videos/play/wwdc2019/810/)
- [Practice Audio Haptic Design (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10278/)

### 커뮤니티
- [24 SwiftUI Performance Tips (2025)](https://medium.com/@ravisolankece12/24-swiftui-performance-tips-every-ios-developer-should-know-2025-edition-723340d9bd79)
- [SwiftUI Animations 2025](https://medium.com/@bhumibhuva18/swiftui-animations-in-2025-beyond-basic-transitions-f63db40c7c46)
- [drawingGroup() for Metal Rendering](https://www.hackingwithswift.com/books/ios-swiftui/enabling-high-performance-metal-rendering-with-drawinggroup)
- [SwiftData Architecture Patterns](https://azamsharp.com/2025/03/28/swiftdata-architecture-patterns-and-practices.html)
- [SwiftData Performance Optimization](https://www.hackingwithswift.com/quick-start/swiftdata/how-to-optimize-the-performance-of-your-swiftdata-apps)
- [Haptic Feedback Guide](https://dev.to/maxnxi/haptic-feedback-in-ios-a-comprehensive-guide-39fb)
- [SwiftUI Gesture Customization](https://fatbobman.com/en/posts/swiftuigesture/)
