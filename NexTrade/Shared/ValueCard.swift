import SwiftUI

struct ValueCard: View {
    let title: String
    let subtitle: String
    let symbol: String

    var body: some View {
        AppCard(padding: AppSpacing.medium, radius: AppRadius.medium) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColor.primaryAccent)
                    .frame(width: 32, height: 32)
                    .background(AppColor.softAccentBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.primaryText)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColor.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
