import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var profile: UserProfile

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avoid ingredients section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("못 먹는 재료", systemImage: "exclamationmark.triangle")
                            .font(.headline)

                        VStack(spacing: 8) {
                            ForEach(UserProfile.allIngredients, id: \.id) { ingredient in
                                Button {
                                    toggleIngredient(ingredient.id)
                                } label: {
                                    HStack {
                                        Text(ingredient.label)
                                            .font(.system(size: 16, weight: .medium))

                                        Spacer()

                                        Image(systemName: profile.avoidIngredients.contains(ingredient.id)
                                              ? "checkmark.circle.fill"
                                              : "circle")
                                            .foregroundColor(
                                                profile.avoidIngredients.contains(ingredient.id)
                                                ? Color(red: 1.0, green: 0.42, blue: 0.42)
                                                : .gray
                                            )
                                            .font(.title3)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(.white)
                                            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                                    )
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                    }

                    // Duplicate avoidance section
                    VStack(alignment: .leading, spacing: 12) {
                        Label("추천 설정", systemImage: "gearshape")
                            .font(.headline)

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("최근 추천 중복 회피")
                                    .font(.system(size: 16, weight: .medium))
                                Text("최근 3일 내 선택한 메뉴를 추천에서 제외해요")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Toggle("", isOn: $profile.avoidDuplicates)
                                .labelsHidden()
                                .tint(Color(red: 1.0, green: 0.42, blue: 0.42))
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                        )
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 1.0, green: 0.976, blue: 0.94).ignoresSafeArea())
            .navigationTitle("설정 ⚙️")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func toggleIngredient(_ id: String) {
        if profile.avoidIngredients.contains(id) {
            profile.avoidIngredients.remove(id)
        } else {
            profile.avoidIngredients.insert(id)
        }
    }
}
