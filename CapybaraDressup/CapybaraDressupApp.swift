import SwiftUI
import SwiftData

@main
struct CapybaraDressupApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Capybara.self)
    }
}

/// 루트 뷰 — 카피바라 보유 여부에 따라 분양/메인 화면 전환
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var capybaras: [Capybara]
    @State private var viewModel = CapybaraViewModel()
    @State private var showAdoption = false

    var body: some View {
        Group {
            if capybaras.isEmpty || showAdoption {
                AdoptionView(viewModel: viewModel) {
                    showAdoption = false
                }
            } else {
                MainView(viewModel: viewModel)
                    .onAppear {
                        // 처음 열 때 마지막 상호작용한 카피바라 선택
                        if viewModel.selectedCapybara == nil,
                           let first = capybaras.sorted(by: {
                               $0.lastInteractedAt > $1.lastInteractedAt
                           }).first {
                            viewModel.select(first)
                        }
                    }
            }
        }
    }
}
