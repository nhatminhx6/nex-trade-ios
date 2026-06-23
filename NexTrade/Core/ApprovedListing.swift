import Foundation

struct ApprovedListing: Identifiable, Hashable {
    let id: String
    let title: String
    let productName: String
    let category: String
    let quantity: String
    let targetMarket: String
    let tradeIntent: TradeIntent
    let neededAt: Date?
    let budget: String
    let description: String
    let createdAt: Date
}

protocol ApprovedListingServiceProtocol: AnyObject {
    func fetchApprovedListings() async throws -> [ApprovedListing]
}
