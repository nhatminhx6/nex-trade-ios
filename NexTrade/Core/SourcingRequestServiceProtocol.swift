import Foundation

protocol SourcingRequestServiceProtocol: AnyObject {
    func submitRequest(_ request: SourcingRequest) async throws
    func fetchRequests() async throws -> [SourcingRequest]
    func fetchRequest(id: String) async throws -> SourcingRequest?
}
