import SwiftUI

struct OptionButton: View {
    let label: String
    let emoji: String?
    let isSelected: Bool
    let isMulti: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let emoji = emoji {
                    Text(emoji)
                        .font(.title3)
                }

                Text(label)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                if isMulti {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? Color(red: 1.0, green: 0.42, blue: 0.42) : .gray.opacity(0.4))
                        .font(.title3)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                Capsule()
                    .fill(isSelected ? Color(red: 1.0, green: 0.42, blue: 0.42).opacity(0.1) : .white)
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color(red: 1.0, green: 0.42, blue: 0.42) : Color.gray.opacity(0.25),
                        lineWidth: isSelected ? 2 : 1.5
                    )
            )
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
    }
}
