import SwiftUI

struct CategoryPill: View {
    let title: String
    var isSelected = false
    var action: (() -> Void)?

    var body: some View {
        Button {
            action?()
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? AppColor.accentDark : AppColor.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.88)
                .padding(.horizontal, 16)
                .frame(height: 42)
                .background(isSelected ? AppColor.softAccentBackground : AppColor.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(isSelected ? AppColor.primaryAccent.opacity(0.42) : AppColor.border.opacity(0.72), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.055), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .fixedSize(horizontal: true, vertical: false)
    }
}
