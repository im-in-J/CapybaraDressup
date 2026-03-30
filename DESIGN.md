# CapybaraDressup - 설계 문서

## 개요
카피바라를 키우고 상호작용하는 iOS 앱. 각 카피바라는 유전자 기반의 고유한 외형을 가지며, 향후 기기 간 접촉을 통한 교배 시스템을 지원한다.

---

## 기술 스택

| 항목 | 선택 | 비고 |
|------|------|------|
| UI 프레임워크 | SwiftUI | iOS 네이티브 |
| 최소 지원 | iOS 16+ | SwiftData 요구 |
| 데이터 저장 | SwiftData | 로컬 영속화 |
| 카피바라 렌더링 | SwiftUI Shape/Path | 코드 드로잉, 유전자 기반 변형 |
| 햅틱 | UIKit (UIImpactFeedbackGenerator) | 터치 반응 |
| 기기 간 통신 (향후) | MultipeerConnectivity | 교배 시스템 |

---

## 핵심 규칙

- 최초 실행 시 카피바라 **1마리만 분양** 가능
- 한 사용자당 최대 **10마리**
- 추가 카피바라는 **교배**로만 획득 (향후 구현)
- 옷 입히기, 시간 경과 시스템은 **2차 개발**

---

## 1. 유전자 시스템 (Genetics)

교배를 대비하여 각 카피바라의 외형을 **유전자(Gene)** 구조로 설계한다. 최초 분양 카피바라는 랜덤 유전자를 가지며, 교배 시 양쪽 부모의 유전자를 조합 + 돌연변이로 자식 유전자를 생성한다.

### 유전자 구조

각 유전자는 0.0~1.0 범위의 Float 값이다. 이 값을 실제 렌더링 파라미터로 매핑한다.

```
Gene                  | 렌더링 효과                    | 매핑 범위
──────────────────────|───────────────────────────────|──────────────
bodyWidth             | 몸통 가로 비율                  | 0.8 ~ 1.2
bodyHeight            | 몸통 세로 비율                  | 0.85 ~ 1.15
headSize              | 머리 크기                      | 0.85 ~ 1.15
noseSize              | 코 크기                        | 0.7 ~ 1.3
noseHeight            | 코 위치 높낮이                  | 0.8 ~ 1.2
earSize               | 귀 크기                        | 0.7 ~ 1.3
earPointiness         | 귀 뾰족한 정도                  | 0.0 ~ 1.0
eyeSize               | 눈 크기                        | 0.8 ~ 1.2
eyeSpacing            | 눈 간격                        | 0.8 ~ 1.2
furHue                | 털 색상 Hue 오프셋              | -15° ~ +15°
furSaturation         | 털 채도 오프셋                  | -0.15 ~ +0.15
furBrightness         | 털 밝기 오프셋                  | -0.1 ~ +0.1
cheekSize             | 볼터치 크기 (0이면 없음)         | 0.0 ~ 1.0
tailLength            | 꼬리 길이                      | 0.7 ~ 1.3
legThickness          | 다리 굵기                      | 0.8 ~ 1.2
```

### 유전자 조합 (교배 시, 향후)

```
자식 유전자[i] = 랜덤(부모A 유전자[i], 부모B 유전자[i])   // 50:50 선택
                + 돌연변이 (5% 확률, ±0.1 범위)
```

---

## 2. 데이터 모델

```swift
// MARK: - 유전자
struct CapybaraGenes: Codable {
    var bodyWidth: Float      // 0~1
    var bodyHeight: Float
    var headSize: Float
    var noseSize: Float
    var noseHeight: Float
    var earSize: Float
    var earPointiness: Float
    var eyeSize: Float
    var eyeSpacing: Float
    var furHue: Float
    var furSaturation: Float
    var furBrightness: Float
    var cheekSize: Float
    var tailLength: Float
    var legThickness: Float

    static func random() -> CapybaraGenes { ... }
    static func breed(parentA: CapybaraGenes, parentB: CapybaraGenes) -> CapybaraGenes { ... }
}

// MARK: - 카피바라
@Model
class Capybara {
    var id: UUID
    var name: String
    var genes: CapybaraGenes       // 외형 결정
    var parentAId: UUID?           // 부모 A (교배용, nil이면 최초 분양)
    var parentBId: UUID?           // 부모 B
    var affection: Double          // 호감도 0~100
    var hunger: Double             // 포만감 0~100
    var createdAt: Date
    var lastInteractedAt: Date
}
```

---

## 3. 터치 상호작용

| 제스처 | 동작 | 효과 | 햅틱 |
|--------|------|------|------|
| 드래그 (쓰다듬기) | 카피바라 위에서 스와이프 | 호감도 +2, 눈 감는 표정, 하트 파티클 | soft |
| 탭 (먹이주기) | 먹이 버튼 탭 | 포만감 +10, 냠냠 애니메이션 | medium |
| 더블탭 (놀기) | 카피바라 더블탭 | 호감도 +5, 점프 애니메이션 | rigid |
| 꾹 누르기 | 롱프레스 | 카피바라가 졸리는 표정, 호감도 +1/초 | soft 반복 |

### 카피바라 표정 상태

```
idle        → 기본 (눈 깜빡임 주기적)
happy       → 쓰다듬기 중 (눈 감김, 입꼬리 올라감)
eating      → 먹이 먹는 중 (입 움직임)
excited     → 놀기 (눈 커짐, 점프)
sleepy      → 롱프레스 (눈 반쯤 감김)
surprised   → 갑작스런 탭 (눈 커짐, 살짝 뒤로)
```

---

## 4. 화면 흐름

```
앱 최초 실행
    │
    ▼
[온보딩 / 분양 화면]
    │  카피바라 1마리 랜덤 생성
    │  이름 입력
    ▼
[메인 화면] ◄──────────────────┐
    │  카피바라 표시 + 상호작용    │
    │  하단: 상태바, 버튼          │
    │                            │
    ├──[카피바라 목록] ───────────┘
    │    보유한 카피바라 그리드
    │    선택하면 메인화면으로
    │
    └──[설정]
         이름 변경
         (향후: 교배, 옷 입히기)
```

---

## 5. 화면 상세

### 5-1. 메인 화면 (MainView)

```
┌─────────────────────────┐
│ [목록]            [설정] │
│                         │
│      ╭─────────╮        │
│      │  "모찌"  │        │  ← 이름 말풍선
│      ╰────┬────╯        │
│           │              │
│       ╭───┴───╮         │
│      ( ◕   ◕  )        │  ← 카피바라 (터치 영역)
│     ╭┤         ├╮       │
│     │ ╰───────╯ │       │
│      ╰─┤     ├─╯        │
│        ┘     └           │
│                          │
│  ♥ 호감도  ████████░░    │
│  ● 포만감  ████░░░░░░    │
│                          │
│   [🌿 먹이주기]          │
└─────────────────────────┘
```

### 5-2. 카피바라 목록 (CapybaraListView)

```
┌─────────────────────────┐
│ ← 뒤로     내 카피바라들  │
│                          │
│  ┌─────┐  ┌─────┐       │
│  │(◕◕) │  │(◕◕) │       │
│  │모찌  │  │콩이  │       │
│  └─────┘  └─────┘       │
│  ┌─────┐                 │
│  │(◕◕) │                 │
│  │두부  │   ... 최대 10   │
│  └─────┘                 │
│                          │
│       3 / 10 마리         │
└─────────────────────────┘
```

### 5-3. 분양 화면 (AdoptionView)

```
┌─────────────────────────┐
│                          │
│   카피바라가 당신을        │
│   기다리고 있어요!         │
│                          │
│       ╭───────╮          │
│      ( ◕   ◕  )         │  ← 랜덤 생성된 카피바라
│     ╭┤         ├╮        │
│     │ ╰───────╯ │        │
│      ╰─────────╯         │
│                          │
│   이름을 지어주세요        │
│   ┌──────────────┐       │
│   │              │       │
│   └──────────────┘       │
│                          │
│   [ 데려가기 ]            │
└─────────────────────────┘
```

---

## 6. 프로젝트 구조

```
CapybaraDressup/
├── CapybaraDressupApp.swift          # 앱 진입점
│
├── Models/
│   ├── Capybara.swift                # @Model 카피바라 엔티티
│   ├── CapybaraGenes.swift           # 유전자 구조체
│   └── CapybaraAppearance.swift      # Gene → 렌더링 파라미터 변환
│
├── ViewModels/
│   └── CapybaraViewModel.swift       # 상호작용 로직, 상태 관리
│
├── Views/
│   ├── MainView.swift                # 메인 화면
│   ├── AdoptionView.swift            # 최초 분양 + 이름짓기
│   ├── CapybaraListView.swift        # 보유 카피바라 목록
│   ├── SettingsView.swift            # 설정
│   │
│   ├── Capybara/
│   │   ├── CapybaraView.swift        # 카피바라 전체 조합 뷰
│   │   ├── CapybaraBodyShape.swift   # 몸통 Shape
│   │   ├── CapybaraHeadShape.swift   # 머리 Shape
│   │   ├── CapybaraFaceView.swift    # 눈, 코, 입, 볼 (표정 포함)
│   │   ├── CapybaraEarShape.swift    # 귀 Shape
│   │   ├── CapybaraLegShape.swift    # 다리 Shape
│   │   └── CapybaraTailShape.swift   # 꼬리 Shape
│   │
│   └── Components/
│       ├── StatusBarView.swift       # 호감도/포만감 바
│       ├── SpeechBubbleView.swift    # 이름 말풍선
│       └── ParticleView.swift        # 하트 파티클 등
│
├── Utils/
│   └── HapticManager.swift           # 햅틱 피드백 유틸
│
└── Resources/
    └── Assets.xcassets
```

---

## 7. 교배 시스템 (2차 개발 예정)

### 기기 간 통신

- **MultipeerConnectivity** 프레임워크 사용
- 두 아이폰이 근접하면 자동 디스커버리
- 양쪽 사용자가 교배할 카피바라를 선택
- 유전자 조합 → 양쪽 기기에 각각 새 카피바라 생성

### 교배 흐름

```
기기A                         기기B
  │                             │
  ├── 근접 감지 ◄──────────────►├── 근접 감지
  │                             │
  ├── 카피바라 선택               ├── 카피바라 선택
  │                             │
  ├── 유전자 교환 ──────────────►├── 유전자 수신
  │   (parentA genes)           │   (parentB genes)
  │                             │
  ├── 자식 유전자 계산            ├── 동일 시드로 계산
  │   breed(A, B, seed)         │   breed(A, B, seed)
  │                             │
  ├── 새 카피바라 저장            ├── 새 카피바라 저장
  │   (동일한 자식)               │   (동일한 자식)
  ▼                             ▼
```

### 교배 규칙 (안)

- 10마리 한도 내에서만 교배 가능
- 같은 카피바라 쌍은 쿨타임 적용 (예: 24시간)
- 교배 시 공유 시드 사용 → 양쪽 기기에 동일한 자식 생성

---

## 8. 1차 개발 범위

### 포함

- [x] 앱 기본 구조 (SwiftUI + SwiftData)
- [x] 유전자 시스템 (CapybaraGenes)
- [x] 카피바라 코드 드로잉 (Shape/Path)
- [x] 최초 분양 + 이름짓기
- [x] 터치 상호작용 (쓰다듬기, 먹이주기, 놀기, 롱프레스)
- [x] 표정 시스템
- [x] 호감도/포만감 상태바
- [x] 카피바라 목록 (최대 10마리)
- [x] 햅틱 피드백

### 제외 (2차 이후)

- [ ] 교배 시스템 (MultipeerConnectivity)
- [ ] 옷 입히기
- [ ] 시간 경과 시스템 (배고픔 등)
- [ ] 알림
- [ ] iCloud 동기화
