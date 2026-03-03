import SwiftUI

struct QuestionFlowView: View {
    let mealTime: String
    @StateObject private var viewModel: QuestionFlowViewModel
    @EnvironmentObject var repository: FoodRepository
    @EnvironmentObject var profile: UserProfile
    @Environment(\.dismiss) private var dismiss

    init(mealTime: String) {
        self.mealTime = mealTime
        _viewModel = StateObject(wrappedValue: QuestionFlowViewModel(mealTime: mealTime))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top: progress header
            ProgressHeaderView(
                current: viewModel.currentIndex + 1,
                total: viewModel.questions.count
            )

            if let question = viewModel.currentQuestion {
                questionCard(question)
                    .id(viewModel.currentIndex)
                    .transition(cardTransition)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentIndex)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 1.0, green: 0.976, blue: 0.94).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if viewModel.canGoBack {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.goBack()
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: viewModel.canGoBack ? "chevron.left" : "xmark")
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

    private var cardTransition: AnyTransition {
        let isForward = viewModel.transitionDirection == .forward
        return .asymmetric(
            insertion: .move(edge: isForward ? .trailing : .leading).combined(with: .opacity),
            removal: .move(edge: isForward ? .leading : .trailing).combined(with: .opacity)
        )
    }

    @ViewBuilder
    private func questionCard(_ question: Question) -> some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 8)

            // Center: question card
            CuteCardView {
                VStack(spacing: 12) {
                    if let firstEmoji = question.options.first?.emoji {
                        Text(firstEmoji)
                            .font(.system(size: 40))
                    }

                    Text(question.title)
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)

                    if let subtitle = question.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }

            // Bottom: option buttons
            VStack(spacing: 10) {
                ForEach(question.options) { option in
                    OptionButton(
                        label: option.label,
                        emoji: option.emoji,
                        isSelected: viewModel.isOptionSelected(option),
                        isMulti: question.type == .multi,
                        action: {
                            triggerHaptic()
                            if question.type == .multi {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.toggleOption(option)
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.selectOption(option)
                                }
                            }
                        }
                    )
                }

                // Confirm button for multi-select
                if question.type == .multi {
                    Button {
                        triggerHaptic()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.confirmMultiSelection()
                        }
                    } label: {
                        Text("다음 →")
                            .font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.42, blue: 0.42),
                                                Color(red: 1.0, green: 0.56, blue: 0.56)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .foregroundColor(.white)
                    }
                    .padding(.top, 6)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func triggerHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

