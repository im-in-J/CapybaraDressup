import SwiftUI
import SwiftData

/// 카피바라 분양 화면 — 최초 실행 시 또는 카피바라가 없을 때 표시
struct AdoptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: CapybaraViewModel

    @State private var name: String = ""
    @State private var previewGenes: CapybaraGenes = .random()
    @State private var isShaking = false

    var onAdopted: () -> Void

    private var previewAppearance: CapybaraAppearance {
        CapybaraAppearance(genes: previewGenes)
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 타이틀
            VStack(spacing: 8) {
                Text("카피바라가 당신을")
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                Text("기다리고 있어요!")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }
            .padding(.bottom, 30)

            // 카피바라 미리보기
            CapybaraView(
                appearance: previewAppearance,
                expression: .idle,
                size: 220
            )
            .onTapGesture {
                // 탭하면 새 유전자로 변경
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    previewGenes = .random()
                    isShaking = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isShaking = false
                }
            }
            .rotationEffect(.degrees(isShaking ? 3 : 0))

            Text("탭하면 다른 카피바라를 볼 수 있어요")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            Spacer()

            // 이름 입력
            VStack(spacing: 16) {
                Text("이름을 지어주세요")
                    .font(.system(size: 17, weight: .medium, design: .rounded))

                TextField("카피바라 이름", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 18, design: .rounded))
                    .frame(maxWidth: 240)

                Button(action: adopt) {
                    Text("데려가기")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 240)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(name.trimmingCharacters(in: .whitespaces).isEmpty
                                      ? Color.gray
                                      : Color.brown)
                        )
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 24)
        .background(
            Color(red: 0.97, green: 0.95, blue: 0.90)
                .ignoresSafeArea()
        )
    }

    private func adopt() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // 미리보기에 표시된 유전자로 분양
        let capybara = Capybara(name: trimmedName, genes: previewGenes)
        modelContext.insert(capybara)
        viewModel.select(capybara)
        onAdopted()
    }
}
