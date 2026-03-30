# 개발 계획 (1차)

## Phase 1: 프로젝트 셋업 + 데이터 레이어

### 1-1. Xcode 프로젝트 생성
- [ ] SwiftUI App 템플릿으로 Xcode 프로젝트 생성
- [ ] iOS 16+ 타겟 설정
- [ ] 폴더 구조 생성 (Models, Views, ViewModels, Utils, Resources)

### 1-2. 데이터 모델
- [ ] `CapybaraGenes` 구조체 (Codable, 외형 15 + 성격 2 파라미터)
- [ ] `CapybaraGenes.random()` — 랜덤 유전자 생성
- [ ] `CapybaraGenes.breed(parentA:parentB:)` — 교배 로직 (향후 사용, 미리 구현)
- [ ] `Capybara` SwiftData @Model (id, name, genes, parentIds, affection, hunger, timestamps)
- [ ] `CapybaraAppearance` — Gene 값을 실제 렌더링 파라미터(CGFloat)로 매핑

### 1-3. ViewModel
- [ ] `CapybaraViewModel` — SwiftData CRUD, 상호작용 로직, 상태 관리
- [ ] 최대 10마리 제한 로직
- [ ] 호감도/포만감 변경 로직

---

## Phase 2: 카피바라 코드 드로잉

### 2-1. 부위별 Shape 구현
- [ ] `CapybaraBodyShape` — 몸통 (bodyWidth, bodyHeight 유전자 반영)
- [ ] `CapybaraHeadShape` — 머리 (headSize 유전자 반영)
- [ ] `CapybaraEarShape` — 귀 (earSize, earPointiness 유전자 반영, 각도 애니메이션)
- [ ] `CapybaraFaceView` — 눈/코/입/볼 (eyeSize, eyeSpacing, noseSize, cheekSize 반영)
- [ ] `CapybaraLegShape` — 다리 4개 (legThickness 반영)
- [ ] `CapybaraTailShape` — 짧은 꼬리 (tailLength 반영)

### 2-2. 조합 + 색상
- [ ] `CapybaraView` — 모든 부위를 ZStack으로 조합
- [ ] 털 색상 적용 (furHue, furSaturation, furBrightness)
- [ ] 랜덤 유전자로 여러 카피바라 렌더링 확인 (프리뷰)

### 2-3. 표정 시스템
- [ ] `ExpressionState` enum (idle, happy, eating, excited, sleepy, surprised, bathing, irritated)
- [ ] 눈 개방도 애니메이션 (0.0 감김 ~ 1.0 최대)
- [ ] 귀 각도 애니메이션 (자연, 옆으로, 앞으로, 뒤로, 위로)
- [ ] 입 모양 변화 (닫힘, 미소, 벌림, 움직임)
- [ ] idle 상태 주기적 눈 깜빡임
- [ ] 성격 유전자(patience, energy) 반영 — 반응 속도/강도 차이

---

## Phase 3: 화면 구현

### 3-1. 분양 화면 (AdoptionView)
- [ ] 랜덤 카피바라 생성 + 미리보기
- [ ] 이름 입력 TextField
- [ ] "데려가기" 버튼 → SwiftData에 저장
- [ ] 앱 최초 실행 판별 (보유 카피바라 0마리면 분양 화면)

### 3-2. 메인 화면 (MainView)
- [ ] 선택된 카피바라 표시 (CapybaraView)
- [ ] 이름 말풍선 (SpeechBubbleView)
- [ ] 상태바 (StatusBarView — 호감도, 포만감)
- [ ] 먹이주기 버튼
- [ ] 상단 네비게이션 (목록, 설정)

### 3-3. 터치 상호작용
- [ ] 드래그 제스처 → 쓰다듬기 (happy 표정, 호감도 +2)
- [ ] 더블탭 → 놀기 (excited 표정, 점프 애니메이션, 호감도 +5)
- [ ] 롱프레스 → 졸리기 (sleepy 표정, 호감도 +1/초)
- [ ] 과도한 터치 감지 → irritated 표정

### 3-4. 물웅덩이
- [ ] 메인 화면 하단에 물웅덩이 영역 렌더링
- [ ] 카피바라 드래그 → 물웅덩이 영역 진입 시 bathing 상태
- [ ] bathing 중 호감도 +3/초
- [ ] patience 유전자에 따른 지속 시간 차이
- [ ] 물방울 파티클 효과

### 3-5. 카피바라 목록 (CapybaraListView)
- [ ] 보유 카피바라 그리드 표시 (미니 CapybaraView)
- [ ] N / 10 마리 카운터
- [ ] 탭하면 해당 카피바라로 메인 화면 전환

### 3-6. 설정 (SettingsView)
- [ ] 이름 변경 기능

---

## Phase 4: 파티클 + 효과음 + 햅틱

### 4-1. 파티클 시스템
- [ ] `ParticleView` — 하트 파티클 (쓰다듬기)
- [ ] 물방울 파티클 (물웅덩이)
- [ ] 별 파티클 (놀기/점프)

### 4-2. 효과음
- [ ] `SoundManager` 유틸 구현
- [ ] purr, click, bark, chatter 4종 효과음 준비
- [ ] 각 상호작용에 맞는 효과음 연결

### 4-3. 햅틱
- [ ] `HapticManager` 유틸 구현
- [ ] 상호작용별 햅틱 강도 매핑 (soft, medium, rigid)

---

## Phase 5: 폴리싱 + 테스트

- [ ] 다양한 유전자 조합으로 카피바라 외형 검증
- [ ] 애니메이션 부드러움 확인
- [ ] 성격 유전자에 따른 행동 차이 확인
- [ ] SwiftData 영속화 테스트 (앱 종료 후 재시작)
- [ ] 10마리 한도 제한 테스트
- [ ] iPhone SE ~ iPhone 15 Pro Max 레이아웃 확인
