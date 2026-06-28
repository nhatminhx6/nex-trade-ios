import SwiftUI

struct ApprovedListingsView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel: ApprovedListingsViewModel
    @State private var selectedIntent: TradeIntent = .buy
    @State private var selectedDateFilter: DashboardDateFilter = .all

    init(service: ApprovedListingServiceProtocol) {
        _viewModel = StateObject(wrappedValue: ApprovedListingsViewModel(service: service))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                feedHeader
                filterBar

                if viewModel.isLoading {
                    ProgressView().tint(AppColor.primaryAccent)
                } else if filteredListings.isEmpty {
                    EmptyStateView(
                        title: container.t("discover.empty.intent.title"),
                        description: container.t("discover.empty.intent.body")
                    )
                } else {
                    LazyVStack(spacing: AppSpacing.small) {
                        ForEach(filteredListings) { listing in
                            ListingCard(listing: listing)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.medium)
        }
        .background(AppColor.background)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await viewModel.load() }
        .task { await viewModel.load() }
        .onAppear {
            Task { await viewModel.load() }
        }
        .onChange(of: container.selectedTab) { _, selectedTab in
            guard selectedTab == .home else { return }
            Task { await viewModel.load() }
        }
    }

    private var feedHeader: some View {
        Text(container.t("discover.title"))
            .font(.title2.weight(.bold))
            .foregroundStyle(AppColor.primaryText)
    }

    private var filterBar: some View {
        HStack(spacing: AppSpacing.small) {
            intentTabs
            dateFilterMenu
        }
    }

    private var intentTabs: some View {
        HStack(spacing: 2) {
            intentTab(.buy)
            intentTab(.sell)
        }
        .padding(3)
        .background(AppColor.backgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                .stroke(AppColor.border.opacity(0.7), lineWidth: 1)
        }
    }

    private func intentTab(_ intent: TradeIntent) -> some View {
        let isSelected = selectedIntent == intent
        return Button {
            selectedIntent = intent
        } label: {
            Text(intent == .buy ? container.t("create.trade.buy") : container.t("create.trade.sell"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.white : AppColor.secondaryText)
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(isSelected ? AppColor.primaryAccent : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var dateFilterMenu: some View {
        Menu {
            ForEach(DashboardDateFilter.allCases) { filter in
                Button {
                    selectedDateFilter = filter
                } label: {
                    if selectedDateFilter == filter {
                        Label(container.t(filter.titleKey), systemImage: "checkmark")
                    } else {
                        Text(container.t(filter.titleKey))
                    }
                }
            }
        } label: {
            HStack(spacing: 7) {
                Text(container.t(selectedDateFilter.titleKey))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.primaryText)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColor.secondaryText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.small, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            }
        }
    }

    private var filteredListings: [ApprovedListing] {
        viewModel.listings.filter { listing in
            listing.tradeIntent == selectedIntent && selectedDateFilter.includes(listing)
        }
    }
}

@MainActor private final class ApprovedListingsViewModel: ObservableObject {
    @Published var listings: [ApprovedListing] = []
    @Published var isLoading = false
    private let service: ApprovedListingServiceProtocol

    init(service: ApprovedListingServiceProtocol) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        listings = (try? await service.fetchApprovedListings()) ?? []
    }
}

private struct ListingCard: View {
    @EnvironmentObject private var container: AppContainer
    let listing: ApprovedListing

    var body: some View {
        AppListItem {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(listing.productName.capitalizingFirstCharacter())
                            .font(.body.weight(.semibold))
                            .foregroundStyle(AppColor.primaryText)
                            .lineLimit(1)

                        HStack(spacing: AppSpacing.small) {
                            if !listing.targetMarket.isEmpty {
                                Label(listing.targetMarket.capitalizingFirstCharacter(), systemImage: "globe.asia.australia.fill")
                            }

                            if !listing.targetMarket.isEmpty && !listing.quantity.isEmpty {
                                Rectangle()
                                    .fill(AppColor.border)
                                    .frame(width: 1, height: 14)
                            }

                            if !listing.quantity.isEmpty {
                                Label("\(listing.quantity) \(container.t("quantity.unit.\(listing.quantityUnit)"))", systemImage: "shippingbox.fill")
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(AppColor.secondaryText)
                        .lineLimit(1)
                    }

                    Spacer(minLength: AppSpacing.small)

                    Text(container.localizedCategory(listing.category).capitalizingFirstCharacter())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColor.secondaryText)
                        .lineLimit(1)
                        .padding(.top, 2)
                }

                if !listing.productDescription.isEmpty {
                    Text(listing.productDescription.capitalizingFirstCharacter())
                        .font(.subheadline)
                        .foregroundStyle(AppColor.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if publishedDate != nil || listing.neededAt != nil {
                    Hairline()

                    HStack(spacing: AppSpacing.small) {
                        if let publishedDate {
                            dateLabel(
                                systemName: "clock",
                                title: "\(container.t("discover.published.prefix")) \(formattedDate(publishedDate, includesTime: true))"
                            )
                        }

                        Spacer(minLength: 0)

                        if let neededAt = listing.neededAt {
                            dateLabel(
                                systemName: "calendar",
                                title: "\(container.t("discover.needed.prefix")) \(formattedDate(neededAt, includesTime: false))"
                            )
                        }
                    }
                }
            }
        }
    }

    private var publishedDate: Date? {
        if let publishedAt = listing.publishedAt { return publishedAt }
        return listing.createdAt == .distantPast ? nil : listing.createdAt
    }

    private func dateLabel(systemName: String, title: String) -> some View {
        Label(title, systemImage: systemName)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(AppColor.secondaryText)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }

    private func formattedDate(_ date: Date, includesTime: Bool) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = includesTime ? "HH:mm · dd/MM" : "dd/MM/yy"
        return formatter.string(from: date)
    }
}

private extension String {
    func capitalizingFirstCharacter() -> String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}

private enum DashboardDateFilter: CaseIterable, Identifiable {
    case all, yesterday, days7, days14, month

    var id: Self { self }

    var titleKey: String {
        switch self {
        case .all: "discover.filter.all"
        case .yesterday: "discover.filter.yesterday"
        case .days7: "discover.filter.days7"
        case .days14: "discover.filter.days14"
        case .month: "discover.filter.month"
        }
    }

    func includes(_ listing: ApprovedListing) -> Bool {
        guard self != .all else { return true }
        let date: Date? = listing.publishedAt ?? (listing.createdAt == .distantPast ? listing.neededAt : listing.createdAt)
        guard let date else { return true }

        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .all:
            return true
        case .yesterday:
            guard let startOfToday = calendar.dateInterval(of: .day, for: now)?.start,
                  let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday) else { return false }
            return date >= startOfYesterday && date < startOfToday
        case .days7:
            guard let start = calendar.date(byAdding: .day, value: -7, to: now) else { return false }
            return date >= start
        case .days14:
            guard let start = calendar.date(byAdding: .day, value: -14, to: now) else { return false }
            return date >= start
        case .month:
            guard let start = calendar.date(byAdding: .month, value: -1, to: now) else { return false }
            return date >= start
        }
    }
}
