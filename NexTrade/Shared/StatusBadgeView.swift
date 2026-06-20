import SwiftUI

struct StatusBadgeView: View {
    @EnvironmentObject private var container: AppContainer
    let status: SourcingRequestStatus

    var body: some View {
        Text(status.localizedBadgeLabel(language: container.language))
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.badgeColor)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(status.badgeColor.opacity(0.12))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(status.badgeColor.opacity(0.18), lineWidth: 1)
            }
    }
}
