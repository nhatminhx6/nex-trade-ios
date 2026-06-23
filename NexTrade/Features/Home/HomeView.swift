import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = HomeDashboardViewModel()

    private let categories = ["category.fruit", "category.vegetables", "category.dryFood", "category.beverage", "category.other"]
    private let values = [
        ("01", "home.value.source.title", "home.value.source.body"),
        ("02", "home.value.verify.title", "home.value.verify.body"),
        ("03", "home.value.response.title", "home.value.response.body")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                heroCard
                operatingSnapshot
                recentRequestsSection
                workflowCard
                categorySection
                valueSection
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColor.background)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.loadRequests(using: container.sourcingRequestService)
        }
        .onAppear {
            Task {
                await viewModel.loadRequests(using: container.sourcingRequestService)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("NexTrade")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppColor.primaryText)

                Text("Modern Trade OS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.secondaryText)
            }

            Spacer()

            Text("MVP")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColor.accentDark)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(AppColor.softAccentBackground)
                .clipShape(Capsule())
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            TradeArtwork()
                .frame(height: 188)

            VStack(alignment: .leading, spacing: 12) {
                Text(container.t("home.hero.eyebrow"))
                    .font(.caption2.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(AppColor.primaryAccent)

                Text(container.t("home.hero.title"))
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(AppColor.primaryText)
                    .lineSpacing(2)

                Text(container.t("home.hero.description"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppColor.secondaryText)
                    .lineSpacing(4)
            }

            NavigationLink {
                CreateRequestView(service: container.sourcingRequestService, currentUser: container.currentUser)
            } label: {
                HStack {
                    Text(container.t("home.cta"))
                        .font(.headline)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.headline.weight(.semibold))
                }
                .foregroundStyle(AppColor.primaryAccent)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(AppColor.surface)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(AppColor.primaryAccent.opacity(0.28), lineWidth: 1)
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [AppColor.heroGradientStart, AppColor.heroGradientEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(AppColor.glassStroke.opacity(0.86), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.14), radius: 28, x: 0, y: 16)
    }

    private var workflowCard: some View {
        AppCard(padding: 18, radius: AppRadius.large) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: container.t("home.workflow"))

                HStack(spacing: 10) {
                    WorkflowChip(number: "1", title: container.t("home.workflow.submit"))
                    ConnectorLine()
                    WorkflowChip(number: "2", title: container.t("home.workflow.review"))
                    ConnectorLine()
                    WorkflowChip(number: "3", title: container.t("home.workflow.response"))
                }
            }
        }
    }

    private var operatingSnapshot: some View {
        AppCard(padding: 18, radius: AppRadius.large) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(container.t("home.snapshot.eyebrow"))
                            .font(.caption2.weight(.bold))
                            .tracking(1.1)
                            .foregroundStyle(AppColor.primaryAccent)

                        Text(container.t("home.snapshot.title"))
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppColor.primaryText)
                    }

                    Spacer()

                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.title3)
                        .foregroundStyle(AppColor.primaryAccent)
                        .frame(width: 38, height: 38)
                        .background(AppColor.softAccentBackground)
                        .clipShape(Circle())
                }

                HStack(spacing: AppSpacing.small) {
                    DashboardMetric(
                        value: viewModel.requests.count,
                        label: container.t("home.snapshot.total"),
                        color: AppColor.primaryAccent
                    )
                    DashboardMetric(
                        value: viewModel.activeCount,
                        label: container.t("home.snapshot.active"),
                        color: AppColor.processing
                    )
                    DashboardMetric(
                        value: viewModel.quotedCount,
                        label: container.t("home.snapshot.quoted"),
                        color: AppColor.success
                    )
                }
            }
        }
    }

    private var recentRequestsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(alignment: .firstTextBaseline) {
                SectionHeader(
                    title: container.t("home.recent.title"),
                    subtitle: container.t("home.recent.subtitle")
                )

                Spacer()

                NavigationLink {
                    RequestsListView()
                } label: {
                    HStack(spacing: 4) {
                        Text(container.t("home.recent.all"))
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.primaryAccent)
                }
            }

            if viewModel.isLoading && viewModel.requests.isEmpty {
                AppCard(padding: 16, radius: AppRadius.medium) {
                    HStack(spacing: AppSpacing.small) {
                        ProgressView()
                            .tint(AppColor.primaryAccent)
                        Text(container.t("home.recent.loading"))
                            .font(.subheadline)
                            .foregroundStyle(AppColor.secondaryText)
                    }
                }
            } else if viewModel.recentRequests.isEmpty {
                AppCard(padding: 16, radius: AppRadius.medium) {
                    HStack(spacing: AppSpacing.medium) {
                        Image(systemName: "tray")
                            .font(.title3)
                            .foregroundStyle(AppColor.primaryAccent)
                            .frame(width: 40, height: 40)
                            .background(AppColor.softAccentBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(container.t("home.recent.empty.title"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColor.primaryText)
                            Text(container.t("home.recent.empty.body"))
                                .font(.caption)
                                .foregroundStyle(AppColor.secondaryText)
                        }
                    }
                }
            } else {
                VStack(spacing: AppSpacing.small) {
                    ForEach(viewModel.recentRequests) { request in
                        NavigationLink {
                            RequestDetailView(request: request)
                        } label: {
                            HomeRequestCard(request: request)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(title: container.t("home.categories"))

            TagWrapLayout(spacing: AppSpacing.small, rowSpacing: AppSpacing.small) {
                ForEach(categories, id: \.self) { category in
                CategoryPill(title: container.localizedCategory(category))
                }
            }
        }
    }

    private var valueSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            SectionHeader(title: container.t("home.support"))

            VStack(spacing: AppSpacing.small) {
                ForEach(values, id: \.0) { item in
                    AppCard(padding: 16, radius: AppRadius.large) {
                        HStack(alignment: .top, spacing: 14) {
                            Text(item.0)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppColor.onAccentChip)
                                .frame(width: 34, height: 34)
                                .background(AppColor.accentChipFill)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(container.t(item.1))
                                    .font(.headline)
                                    .foregroundStyle(AppColor.primaryText)
                                Text(container.t(item.2))
                                    .font(.subheadline)
                                    .foregroundStyle(AppColor.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct DashboardMetric: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value.formatted())
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColor.primaryText)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(AppColor.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
    }
}

private struct HomeRequestCard: View {
    @EnvironmentObject private var container: AppContainer
    let request: SourcingRequest

    var body: some View {
        AppCard(padding: 16, radius: AppRadius.medium) {
            HStack(spacing: AppSpacing.medium) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(request.status.badgeColor)
                    .frame(width: 4, height: 42)

                VStack(alignment: .leading, spacing: 5) {
                    Text(request.productName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColor.primaryText)
                        .lineLimit(1)

                    Text("\(container.localizedCategory(request.category)) · \(request.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(AppColor.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: AppSpacing.small)

                VStack(alignment: .trailing, spacing: AppSpacing.xsmall) {
                    StatusBadgeView(status: request.status)
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppColor.secondaryText)
                }
            }
        }
    }
}

private struct TradeArtwork: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppColor.artworkStart, AppColor.artworkEnd],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            ForEach(0..<5) { index in
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(AppColor.glassStroke.opacity(0.22))
                    .frame(width: 20 + CGFloat(index * 9), height: 72 + CGFloat(index * 14))
                    .offset(x: CGFloat(index * 34) - 82, y: CGFloat(index * -4) + 22)
            }

            Circle()
                .stroke(AppColor.primaryAccent.opacity(0.18), lineWidth: 18)
                .frame(width: 132, height: 132)
                .offset(x: 70, y: -8)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColor.surface.opacity(0.92))
                .frame(width: 138, height: 92)
                .overlay {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(AppColor.primaryAccent)
                                .frame(width: 10, height: 10)
                            Text(container.t("home.art.source"))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(AppColor.secondaryText)
                        }

                        Text(container.t("home.art.route"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColor.primaryText)

                        Capsule()
                            .fill(AppColor.primaryAccent)
                            .frame(width: 82, height: 5)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .offset(x: -34, y: 28)
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 10)

            Image(systemName: "shippingbox")
                .font(.system(size: 42, weight: .light))
                .foregroundStyle(AppColor.primaryAccent.opacity(0.78))
                .offset(x: 72, y: 40)
        }
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct WorkflowChip: View {
    let number: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Text(number)
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppColor.onAccentChip)
                .frame(width: 24, height: 24)
                .background(AppColor.accentChipFill)
                .clipShape(Circle())

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(minHeight: 32)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ConnectorLine: View {
    var body: some View {
        Rectangle()
            .fill(AppColor.border)
            .frame(width: 18, height: 1)
            .offset(y: -17)
    }
}

private struct TagWrapLayout: Layout {
    let spacing: CGFloat
    let rowSpacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let availableWidth = proposal.width ?? .greatestFiniteMagnitude
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextWidth = lineWidth == 0 ? size.width : lineWidth + spacing + size.width

            if nextWidth > availableWidth, lineWidth > 0 {
                totalHeight += lineHeight + rowSpacing
                maxWidth = max(maxWidth, lineWidth)
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth = nextWidth
                lineHeight = max(lineHeight, size.height)
            }
        }

        totalHeight += lineHeight
        maxWidth = max(maxWidth, lineWidth)
        return CGSize(width: proposal.width ?? maxWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var origin = bounds.origin
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextX = origin.x == bounds.minX ? origin.x + size.width : origin.x + spacing + size.width

            if nextX > bounds.maxX, origin.x > bounds.minX {
                origin.x = bounds.minX
                origin.y += lineHeight + rowSpacing
                lineHeight = 0
            } else if origin.x > bounds.minX {
                origin.x += spacing
            }

            subview.place(
                at: origin,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
            origin.x += size.width
            lineHeight = max(lineHeight, size.height)
        }
    }
}
