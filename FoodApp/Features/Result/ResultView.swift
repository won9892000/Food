import SwiftUI

struct ResultView: View {
    let answers: [String: String]
    let foods: [Food]

    @StateObject private var viewModel: ResultViewModel
    @EnvironmentObject var repository: FoodRepository
    @EnvironmentObject var profile: UserProfile
    @Environment(\.dismiss) private var dismiss

    init(answers: [String: String], foods: [Food]) {
        self.answers = answers
        self.foods = foods
        _viewModel = StateObject(wrappedValue: ResultViewModel(answers: answers, foods: foods))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let saved = viewModel.savedFood {
                    confirmationView(saved)
                } else {
                    resultListView
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 1.0, green: 0.976, blue: 0.94).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if viewModel.results.isEmpty {
                viewModel.generateResults(
                    avoidIngredients: profile.avoidIngredients,
                    recentIds: profile.avoidDuplicates ? repository.recentFoodIds(days: 3) : [],
                    avoidDuplicates: profile.avoidDuplicates
                )
            }
        }
    }

    private var resultListView: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("😋")
                    .font(.system(size: 56))
                Text("이런 메뉴 어때요?")
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.bottom, 8)

            // Food cards
            ForEach(viewModel.results) { result in
                foodCard(result)
            }

            // Actions
            VStack(spacing: 10) {
                Button {
                    viewModel.retryExcludingCurrent(
                        avoidIngredients: profile.avoidIngredients,
                        recentIds: profile.avoidDuplicates ? repository.recentFoodIds(days: 3) : [],
                        avoidDuplicates: profile.avoidDuplicates
                    )
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("다시 추천 🔄")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 1.0, green: 0.42, blue: 0.42), lineWidth: 2)
                    )
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.42))
                }

                Button {
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "house")
                        Text("질문 다시하기 🏠")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.15))
                    )
                    .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
    }

    private func foodCard(_ result: RecommendResult) -> some View {
        VStack(spacing: 12) {
            Text(result.food.emoji)
                .font(.system(size: 48))

            Text(result.food.name)
                .font(.system(size: 20, weight: .bold))

            Text(result.reason)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                Button {
                    viewModel.saveChoice(result.food, repository: repository)
                } label: {
                    Text("이거 먹을래! ✅")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.42, blue: 0.42), Color(red: 1.0, green: 0.56, blue: 0.56)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundColor(.white)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
    }

    private func confirmationView(_ food: Food) -> some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)

            Text("🎉")
                .font(.system(size: 64))

            Text("오늘은 \(food.emoji) \(food.name)!")
                .font(.system(size: 22, weight: .bold))

            Text("맛있게 드세요~ 😋")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer().frame(height: 32)

            Button {
                dismiss()
            } label: {
                Text("홈으로 🏠")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.42, blue: 0.42), Color(red: 1.0, green: 0.56, blue: 0.56)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .foregroundColor(.white)
            }
        }
    }
}
