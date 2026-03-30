# CapybaraDressup - Claude Code 가이드

## 프로젝트 개요

카피바라 키우기 iOS 앱. SwiftUI + SwiftData 기반. 유전자 시스템으로 각 카피바라마다 고유한 외형과 성격을 가짐.

## 기술 스택

- **언어**: Swift 5.9+
- **UI**: SwiftUI (UIKit 사용 금지, 햅틱 등 필수 경우만 예외)
- **데이터**: SwiftData (@Model)
- **최소 타겟**: iOS 17.0
- **아키텍처**: MVVM (Model-View-ViewModel)

## 프로젝트 구조

```
CapybaraDressup/
├── Models/          # SwiftData 모델, 유전자, 외형 파라미터
├── ViewModels/      # 비즈니스 로직, 상태 관리
├── Views/           # SwiftUI 화면
│   ├── Capybara/    # 카피바라 드로잉 (Shape/Path 부위별)
│   └── Components/  # 재사용 UI 컴포넌트
├── Utils/           # HapticManager, SoundManager
└── Resources/       # Assets, Sounds
```

## 코딩 컨벤션

### Swift 스타일
- Swift API Design Guidelines 준수
- 들여쓰기: 4 spaces
- 네이밍: camelCase (변수/함수), PascalCase (타입)
- 한 줄 최대 120자
- `self.` 는 컴파일러가 요구할 때만 사용

### SwiftUI 규칙
- View body는 가능한 한 간결하게 유지, 복잡하면 subview로 추출
- `@State`, `@Binding`, `@Observable` 적절히 사용
- 하드코딩 사이즈 지양, `GeometryReader` 또는 상대적 사이즈 사용
- 색상은 Asset Catalog 또는 `Color` extension에서 관리
- Preview를 반드시 포함 (`#Preview`)

### SwiftData 규칙
- `@Model` 클래스는 Models/ 폴더에 위치
- 복잡한 타입(예: CapybaraGenes)은 Codable로 직렬화하여 저장
- ModelContainer 설정은 App 진입점에서 수행

### Shape/Path 드로잉 규칙
- 카피바라 각 부위는 별도 Shape 파일로 분리
- 유전자 값(0~1)을 렌더링 파라미터로 매핑하는 로직은 CapybaraAppearance에 집중
- Shape 내부에서 직접 유전자 값을 사용하지 않고, 변환된 CGFloat 값을 받음
- 모든 좌표는 정규화(0~1 범위)로 작성 후 frame 크기에 맞게 스케일

## 핵심 도메인 규칙

- 카피바라 최대 보유 수: **10마리**
- 최초 실행 시 **1마리만 분양** (랜덤 유전자)
- 추가 카피바라는 교배로만 획득 (2차 구현)
- 유전자는 외형 15개 + 성격 2개, 모두 0.0~1.0 범위 Float
- 호감도/포만감은 0~100 범위 Double

## 빌드 & 실행

```bash
# Xcode로 프로젝트 열기
open CapybaraDressup.xcodeproj

# CLI 빌드 (시뮬레이터)
xcodebuild -scheme CapybaraDressup -destination 'platform=iOS Simulator,name=iPhone 16' build

# 테스트
xcodebuild -scheme CapybaraDressup -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## 참고 문서

- `DESIGN.md` — 전체 설계 문서 (유전자 시스템, 화면 흐름, 교배 시스템 등)
- `plan.md` — 개발 계획 (Phase별 태스크)
- `skill.md` — iOS 게임 개발 기술 가이드 (성능, 드로잉, 제스처, 햅틱 등)
