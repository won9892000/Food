import SwiftUI

struct ProgressHeaderView: View {
    let current: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 1.0 }
        return Double(current) / Double(total)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(current) / \(total)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.18))
                        .frame(height: 5)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.42, blue: 0.42),
                                    Color(red: 1.0, green: 0.85, blue: 0.24)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 5)
                        .animation(.easeInOut(duration: 0.35), value: progress)
                }
            }
            .frame(height: 5)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }
}
