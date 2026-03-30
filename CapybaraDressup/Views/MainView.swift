import SwiftUI
import SwiftData

/// 메인 화면 — 카피바라 표시, 터치 상호작용, 물웅덩이, 상태바
struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: CapybaraViewModel

    @State private var showList = false
    @State private var showSettings = false
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    // 물웅덩이 드롭 영역 판정
    @State private var waterPuddleFrame: CGRect = .zero

    var body: some View {
        NavigationStack {
            ZStack {
                // 배경
                backgroundGradient

                VStack(spacing: 0) {
                    // 상단 네비게이션
                    topBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    Spacer()

                    if let capybara = viewModel.selectedCapybara,
                       let appearance = viewModel.appearance {
                        // 이름 말풍선
                        SpeechBubbleView(text: capybara.name)
                            .padding(.bottom, 4)

                        // 카피바라 + 파티클
                        ZStack {
                            CapybaraView(
                                appearance: appearance,
                                expression: viewModel.expression,
                                size: 250
                            )
                            .offset(dragOffset)

                            // 파티클
                            if let particleType = viewModel.showParticles {
                                ParticleView(type: particleType)
                                    .frame(width: 250, height: 250)
                                    .offset(dragOffset)
                                    .allowsHitTesting(false)
                            }
                        }
                        .gesture(combinedGesture)

                        Spacer()

                        // 물웅덩이
                        WaterPuddleView(isOccupied: viewModel.isInWater)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.onAppear {
                                        waterPuddleFrame = geo.frame(in: .global)
                                    }
                                }
                            )
                            .padding(.bottom, 16)

                        // 상태바
                        StatusBarView(
                            affection: capybara.affection,
                            hunger: capybara.hunger
                        )
                        .padding(.bottom, 12)

                        // 먹이주기 버튼
                        Button(action: { viewModel.feed() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "leaf.fill")
                                Text("먹이주기")
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.8))
                            )
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationDestination(isPresented: $showList) {
                CapybaraListView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }

    // MARK: - 상단 바

    private var topBar: some View {
        HStack {
            Button(action: { showList = true }) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 20))
                    .foregroundStyle(.brown)
            }

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundStyle(.brown)
            }
        }
    }

    // MARK: - 배경

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.95, blue: 0.90),
                Color(red: 0.92, green: 0.90, blue: 0.83)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - 제스처 조합

    private var combinedGesture: some Gesture {
        let drag = DragGesture(minimumDistance: 5)
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation

                // 물웅덩이 위인지 체크
                let fingerPos = CGPoint(
                    x: waterPuddleFrame.midX + value.translation.width,
                    y: waterPuddleFrame.midY + value.translation.height
                )
                let isOverWater = waterPuddleFrame.contains(fingerPos)

                if isOverWater && !viewModel.isInWater {
                    viewModel.enterWater()
                }

                // 드래그 중이면 쓰다듬기
                if !isOverWater {
                    viewModel.pet()
                }
            }
            .onEnded { _ in
                isDragging = false
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    dragOffset = .zero
                }
                if viewModel.isInWater {
                    viewModel.exitWater()
                }
            }

        let doubleTap = TapGesture(count: 2)
            .onEnded {
                viewModel.play()
            }

        let singleTap = TapGesture(count: 1)
            .onEnded {
                viewModel.surprise()
            }

        let longPress = LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in
                viewModel.startLongPress()
            }

        return doubleTap
            .exclusively(before: singleTap)
            .simultaneously(with: drag)
            .simultaneously(with: longPress)
    }
}
