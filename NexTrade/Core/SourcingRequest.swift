import Foundation

enum TradeIntent: String, CaseIterable, Hashable {
    case buy, sell
}

struct SourcingRequest: Identifiable, Hashable {
    let id: String
    let productName: String
    let category: String
    let quantity: String
    let targetMarket: String
    let tradeIntent: TradeIntent
    let neededAt: Date
    let budget: String
    let note: String
    let contactName: String
    let contactPhone: String
    let contactEmail: String
    let status: SourcingRequestStatus
    let adminNote: String?
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        productName: String,
        category: String,
        quantity: String,
        targetMarket: String,
        tradeIntent: TradeIntent = .buy,
        neededAt: Date = Date(),
        budget: String,
        note: String,
        contactName: String,
        contactPhone: String,
        contactEmail: String,
        status: SourcingRequestStatus = .new,
        adminNote: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.productName = productName
        self.category = category
        self.quantity = quantity
        self.targetMarket = targetMarket
        self.tradeIntent = tradeIntent
        self.neededAt = neededAt
        self.budget = budget
        self.note = note
        self.contactName = contactName
        self.contactPhone = contactPhone
        self.contactEmail = contactEmail
        self.status = status
        self.adminNote = adminNote
        self.createdAt = createdAt
    }
}
