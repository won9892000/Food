import SwiftUI

struct QuestionFlowView: View {
    let mealTime: String
    @StateObject private var viewModel: QuestionFlowViewModel
    @EnvironmentObject var repository: FoodRepository
    @EnvironmentObject var profile: UserProfile
    @Environment(\.dismiss) private var dismiss

    init(mealTime: String) {
        self.mealTime = mealTime
        // Questions will be set via onAppear since we need EnvironmentObject
        _viewModel = StateObject(wrappedValue: QuestionFlowViewModel(questions: [], mealTime: mealTime))
    }

    var body: some View {
        VStack(spacing: 0) {
            if let question = viewModel.currentQuestion {
                questionContent(question)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 1.0, green: 0.976, blue: 0.94).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            viewModel.loadQuestions(repository.questions)
        }
        .navigationDestination(isPresented: $viewModel.isFinished) {
            ResultView(
                answers: viewModel.answers,
                foods: repository.foods
            )
        }
    }

    @ViewBuilder
    private func questionContent(_ question: Question) -> some View {
        VStack(spacing: 24) {
            // Character emoji
            Text(question.emoji)
                .font(.system(size: 64))
                .padding(.top, 32)

            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.42, blue: 0.42), Color(red: 1.0, green: 0.85, blue: 0.24)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * viewModel.progress, height: 8)
                            .animation(.easeInOut(duration: 0.4), value: viewModel.progress)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 24)

                Text(viewModel.progressText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Question bubble
            VStack {
                Text(question.text)
                    .font(.system(size: 22, weight: .bold))
                    .padding(24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            )
            .padding(.horizontal, 24)

            // Options
            VStack(spacing: 10) {
                ForEach(question.options) { option in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectOption(option)
                        }
                    } label: {
                        Text(option.label)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(.white)
                                    )
                            )
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }
}
