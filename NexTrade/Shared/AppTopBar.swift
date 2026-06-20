import SwiftUI

struct AppTopBar: View {
    let eyebrow: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow)
                .font(.caption2.weight(.bold))
                .tracking(1.4)
                .foregroundStyle(AppColor.primaryAccent)

            Text(title)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(AppColor.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Hairline: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.border)
            .frame(height: 1)
    }
}
