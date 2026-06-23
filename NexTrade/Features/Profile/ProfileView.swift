import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var container: AppContainer

    private let services = [
        "service.sourcing",
        "service.verify",
        "service.quote"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                accountCard
                serviceSummaryCard
                contactCard
                currentServicesCard
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColor.background)
        .navigationTitle(container.t("profile.title"))
    }

    @ViewBuilder
    private var accountCard: some View {
        if case let .authenticated(user) = container.authState {
            AppCard(padding: 18, radius: AppRadius.large) {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title)
                        .foregroundStyle(AppColor.primaryAccent)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.displayName)
                            .font(.headline)
                            .foregroundStyle(AppColor.primaryText)
                        Text(user.email)
                            .font(.caption)
                            .foregroundStyle(AppColor.secondaryText)
                    }

                    Spacer()

                    Button(container.t("profile.logout")) {
                        Task { await container.logout() }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.primaryAccent)
                }
            }
        }
    }

    private var serviceSummaryCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NEXTRADE")
                        .font(AppTypography.eyebrow)
                        .tracking(1.2)
                        .foregroundStyle(AppColor.primaryAccent)

                    Text(container.t("profile.service"))
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(AppColor.primaryText)
                }

                Spacer()

                Text("OS")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(AppColor.primaryAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Text(container.t("profile.summary"))
                .font(.body)
                .foregroundStyle(AppColor.secondaryText)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.xlarge, style: .continuous)
                .stroke(AppColor.glassStroke.opacity(0.86), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 14)
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(title: container.t("profile.contact"))

            AppCard(padding: 0, radius: AppRadius.large) {
                VStack(spacing: 0) {
                    ProfileRow(symbol: "message", title: "Zalo", value: container.t("profile.updating"))
                    ProfileRow(symbol: "envelope", title: "Email", value: "contact@nextrade.vn")
                    ProfileRow(symbol: "phone", title: "Hotline", value: container.t("profile.updating"))
                }
            }
        }
    }

    private var currentServicesCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(title: container.t("profile.current.services"))

            AppCard(padding: 0, radius: AppRadius.large) {
                VStack(spacing: 0) {
                    ForEach(services, id: \.self) { service in
                        ProfileRow(symbol: "checkmark", title: container.t(service), value: container.t("profile.in.progress"))
                    }
                }
            }
        }
    }
}

private struct ProfileRow: View {
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColor.primaryAccent)
                .frame(width: 32, height: 32)
                .background(AppColor.softAccentBackground)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppColor.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.secondaryText)
            }

            Spacer()
        }
        .padding(AppSpacing.medium)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColor.border)
                .frame(height: 1)
                .padding(.leading, 60)
        }
    }
}
