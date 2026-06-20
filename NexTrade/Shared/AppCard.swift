import SwiftUI

struct AppCard<Content: View>: View {
    var padding: CGFloat = AppSpacing.large
    var radius: CGFloat = AppRadius.large
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(AppColor.glassStroke.opacity(0.82), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 22, x: 0, y: 12)
    }
}
