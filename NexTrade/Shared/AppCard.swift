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

/// A compact, low-radius container for operational queues and feed rows.
struct AppListItem<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                    .stroke(AppColor.border.opacity(0.72), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(0.045), radius: 8, x: 0, y: 4)
    }
}
