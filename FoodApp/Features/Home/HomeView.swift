import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var repository: FoodRepository
    @EnvironmentObject var profile: UserProfile

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Text("🍽️")
                        .font(.system(size: 80))

                    Text("오늘 뭐 먹지?")
                        .font(.system(size: 28, weight: .heavy))

                    Text("간단한 질문으로 딱 맞는 메뉴 추천!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)

                VStack(spacing: 12) {
                    ForEach(mealOptions, id: \.value) { option in
                        Button {
                            viewModel.startRecommendation(mealTime: option.value)
                        } label: {
                            HStack {
                                Text(option.emoji)
                                    .font(.title2)
                                Text(option.label)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(option.color)
                            )
                            .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BgColor", bundle: nil).opacity(0.01).ignoresSafeArea())
            .background(Color(red: 1.0, green: 0.976, blue: 0.94).ignoresSafeArea())
            .navigationDestination(isPresented: $viewModel.showQuestionFlow) {
                QuestionFlowView(mealTime: viewModel.selectedMealTime)
            }
        }
    }

    private var mealOptions: [(label: String, value: String, emoji: String, color: Color)] {
        [
            ("점심 추천", "lunch", "🍱", Color(red: 1.0, green: 0.42, blue: 0.42)),
            ("저녁 추천", "dinner", "🌙", Color(red: 0.58, green: 0.46, blue: 0.9)),
            ("야식 추천", "late", "🌃", Color(red: 0.3, green: 0.3, blue: 0.55))
        ]
    }
}
