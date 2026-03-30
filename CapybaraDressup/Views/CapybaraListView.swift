import SwiftUI
import SwiftData

/// 보유한 카피바라 목록 — 그리드 형태
struct CapybaraListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CapybaraViewModel

    @Query(sort: \Capybara.createdAt, order: .forward)
    private var capybaras: [Capybara]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 카운터
                Text("\(capybaras.count) / \(CapybaraViewModel.maxCapybaras) 마리")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                // 그리드
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(capybaras) { capybara in
                        CapybaraCard(
                            capybara: capybara,
                            isSelected: capybara.id == viewModel.selectedCapybara?.id
                        )
                        .onTapGesture {
                            viewModel.select(capybara)
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("내 카피바라들")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Color(red: 0.97, green: 0.95, blue: 0.90)
                .ignoresSafeArea()
        )
    }
}

// MARK: - 카드

private struct CapybaraCard: View {
    let capybara: Capybara
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            CapybaraMiniView(
                appearance: CapybaraAppearance(genes: capybara.genes)
            )

            Text(capybara.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(
                    color: isSelected ? Color.brown.opacity(0.3) : Color.black.opacity(0.06),
                    radius: isSelected ? 6 : 3,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.brown : Color.clear, lineWidth: 2)
        )
    }
}
