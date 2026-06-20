import Foundation

@MainActor
final class HomeDashboardViewModel: ObservableObject {
    @Published private(set) var requests: [SourcingRequest] = []
    @Published private(set) var isLoading = false

    var activeCount: Int {
        requests.filter { $0.status == .new || $0.status == .reviewing }.count
    }

    var quotedCount: Int {
        requests.filter { $0.status == .quoted }.count
    }

    var recentRequests: [SourcingRequest] {
        Array(requests.prefix(3))
    }

    func loadRequests(using service: SourcingRequestServiceProtocol) async {
        isLoading = true
        defer { isLoading = false }

        do {
            requests = try await service.fetchRequests()
        } catch {
            requests = []
        }
    }
}
