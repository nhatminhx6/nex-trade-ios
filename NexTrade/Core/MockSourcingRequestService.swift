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

    func updateRequest(_ request: SourcingRequest) async throws {
        guard let index = requests.firstIndex(where: { $0.id == request.id }) else { return }
        requests[index] = request
    }

    func deleteRequest(id: String) async throws {
        requests.removeAll { $0.id == id }
    }
}
