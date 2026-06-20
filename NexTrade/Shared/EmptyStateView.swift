import SwiftUI

struct EmptyStateView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(AppColor.primaryAccent)
                .frame(width: 62, height: 62)
                .background(AppColor.softAccentBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.large, style: .continuous))

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColor.primaryText)

            Text(description)
                .font(.body)
                .foregroundStyle(AppColor.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        }
    }
}
