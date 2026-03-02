import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var repository: FoodRepository

    var body: some View {
        NavigationStack {
            Group {
                if repository.history.isEmpty {
                    emptyView
                } else {
                    historyList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 1.0, green: 0.976, blue: 0.94).ignoresSafeArea())
            .navigationTitle("먹은 기록 📋")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Text("🍽️")
                .font(.system(size: 56))
            Text("아직 선택한 음식이 없어요")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(repository.history) { item in
                    HStack(spacing: 12) {
                        Text(item.foodEmoji)
                            .font(.system(size: 28))

                        Text(item.foodName)
                            .font(.system(size: 16, weight: .semibold))

                        Spacer()

                        Text(item.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}
