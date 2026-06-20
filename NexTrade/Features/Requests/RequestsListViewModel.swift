import Foundation

enum RequestsFilter: Hashable {
    case all
    case status(SourcingRequestStatus)
}

@MainActor
final class RequestsListViewModel: ObservableObject {
    @Published var requests: [SourcingRequest] = []
    @Published var errorMessageKey: String?
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedFilter: RequestsFilter = .all

    private let service: SourcingRequestServiceProtocol

    init(service: SourcingRequestServiceProtocol) {
        self.service = service
    }

    func loadRequests() async {
        isLoading = true
        errorMessageKey = nil
        defer { isLoading = false }

        do {
            requests = try await service.fetchRequests()
        } catch {
            errorMessageKey = "error.load"
        }
    }

    var filteredRequests: [SourcingRequest] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return requests
            .filter { request in
                selectedFilter == .all || selectedFilter == .status(request.status)
            }
            .filter { request in
                query.isEmpty || request.productName.localizedCaseInsensitiveContains(query) || request.targetMarket.localizedCaseInsensitiveContains(query)
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func count(for filter: RequestsFilter) -> Int {
        switch filter {
        case .all:
            requests.count
        case let .status(status):
            requests.filter { $0.status == status }.count
        }
    }
}
