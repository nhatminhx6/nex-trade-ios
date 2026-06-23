import Foundation

actor MockSourcingRequestService: SourcingRequestServiceProtocol {
    private var requests: [SourcingRequest] = []

    func submitRequest(_ request: SourcingRequest) async throws {
        requests.insert(request, at: 0)
    }

    func fetchRequests() async throws -> [SourcingRequest] {
        requests
    }

    func fetchRequest(id: String) async throws -> SourcingRequest? {
        requests.first { $0.id == id }
    }
}
