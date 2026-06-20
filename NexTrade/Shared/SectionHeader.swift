import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColor.primaryText)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
