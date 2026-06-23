import SwiftUI

struct RequestsListView: View {
    @EnvironmentObject private var container: AppContainer

    var body: some View {
        RequestsListContentView(viewModel: RequestsListViewModel(service: container.sourcingRequestService))
    }
}

private struct RequestsListContentView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject var viewModel: RequestsListViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                AppTopBar(eyebrow: "CASE QUEUE", title: container.t("requests.queue"))
                    .padding(.top, AppSpacing.small)

                requestControls
                content
            }
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColor.background)
        .navigationTitle(container.t("requests.title"))
        .refreshable {
            await viewModel.loadRequests()
        }
        .onAppear {
            Task {
                await viewModel.loadRequests()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.requests.isEmpty {
            AppCard {
                HStack(spacing: AppSpacing.medium) {
                    ProgressView()
                        .tint(AppColor.primaryAccent)

                    Text(container.t("requests.loading"))
                        .foregroundStyle(AppColor.secondaryText)
                }
            }
        } else if viewModel.requests.isEmpty {
            EmptyStateView(
                title: container.t("requests.empty.title"),
                description: container.t("requests.empty.description")
            )
        } else if viewModel.filteredRequests.isEmpty {
            AppCard(padding: AppSpacing.large, radius: AppRadius.large) {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                        .foregroundStyle(AppColor.primaryAccent)

                    Text(container.t("requests.filter.empty.title"))
                        .font(.headline)
                        .foregroundStyle(AppColor.primaryText)

                    Text(container.t("requests.filter.empty.description"))
                        .font(.subheadline)
                        .foregroundStyle(AppColor.secondaryText)
                }
            }
        } else {
            VStack(spacing: AppSpacing.medium) {
                ForEach(viewModel.filteredRequests) { request in
                    NavigationLink {
                        RequestDetailView(request: request)
                    } label: {
                        RequestRowCard(request: request)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var requestControls: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: "magnifyingglass")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColor.secondaryText)

                TextField(container.t("requests.search.placeholder"), text: $viewModel.searchText)
                    .font(.subheadline)
                    .foregroundStyle(AppColor.primaryText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColor.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            }

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text(container.t("requests.filter.title"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColor.secondaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.small) {
                        ForEach(filters, id: \.self) { filter in
                            RequestsFilterPill(
                                title: filterTitle(filter),
                                count: viewModel.count(for: filter),
                                isSelected: viewModel.selectedFilter == filter
                            ) {
                                viewModel.selectedFilter = filter
                            }
                        }
                    }
                    .padding(.vertical, 1)
                }
            }
        }
    }

    private var filters: [RequestsFilter] {
        [.all] + SourcingRequestStatus.allCases.map(RequestsFilter.status)
    }

    private func filterTitle(_ filter: RequestsFilter) -> String {
        switch filter {
        case .all:
            container.t("requests.filter.all")
        case let .status(status):
            status.localizedBadgeLabel(language: container.language)
        }
    }
}

private struct RequestsFilterPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Text(title)
                Text(count.formatted())
                    .foregroundStyle(isSelected ? AppColor.onAccentChip : AppColor.secondaryText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? AppColor.accentChipFill.opacity(0.82) : AppColor.backgroundElevated)
                    .clipShape(Capsule())
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(isSelected ? AppColor.accentDark : AppColor.primaryText)
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(isSelected ? AppColor.softAccentBackground : AppColor.surface)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? AppColor.primaryAccent.opacity(0.4) : AppColor.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct RequestRowCard: View {
    @EnvironmentObject private var container: AppContainer
    let request: SourcingRequest

    var body: some View {
        AppListItem {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(request.productName)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppColor.primaryText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: AppSpacing.small)

                    StatusBadgeView(status: request.status)
                }

                Hairline()
                    .padding(.vertical, 10)

                HStack(spacing: 8) {
                    Image(systemName: "clock")
                    Text(request.createdAt.formatted(date: .abbreviated, time: .shortened))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .font(.subheadline)
                .foregroundStyle(AppColor.secondaryText)
            }
        }
    }
}

private struct MetadataText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(AppTypography.metadata)
            .foregroundStyle(AppColor.secondaryText)
    }
}

private struct MetadataDot: View {
    var body: some View {
        Circle()
            .fill(AppColor.border)
            .frame(width: 4, height: 4)
    }
}
