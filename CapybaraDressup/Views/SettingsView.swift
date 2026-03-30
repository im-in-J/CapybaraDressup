import SwiftUI

/// 설정 화면 — 이름 변경
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: CapybaraViewModel

    @State private var newName: String = ""
    @State private var showRenamed = false

    var body: some View {
        Form {
            if let capybara = viewModel.selectedCapybara {
                Section("현재 카피바라") {
                    HStack {
                        Text("이름")
                        Spacer()
                        Text(capybara.name)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("이름 변경") {
                    TextField("새 이름", text: $newName)
                        .onAppear { newName = capybara.name }

                    Button("변경하기") {
                        let trimmed = newName.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        viewModel.rename(capybara, to: trimmed)
                        showRenamed = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showRenamed = false
                        }
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                if showRenamed {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("이름이 변경되었습니다")
                        }
                    }
                }

                Section("정보") {
                    HStack {
                        Text("호감도")
                        Spacer()
                        Text("\(Int(capybara.affection))")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("포만감")
                        Spacer()
                        Text("\(Int(capybara.hunger))")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("함께한 날")
                        Spacer()
                        Text(capybara.createdAt, style: .date)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Section {
                    Text("선택된 카피바라가 없습니다")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
    }
}
