import Foundation

enum TradeIntent: String, CaseIterable, Hashable {
    case buy, sell
}

struct SourcingRequest: Identifiable, Hashable {
    let id: String
    let productName: String
    let category: String
    let quantity: String
    let quantityUnit: String
    let targetMarket: String
    let tradeIntent: TradeIntent
    let neededAt: Date
    let productDescription: String
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
        quantityUnit: String = "kg",
        targetMarket: String,
        tradeIntent: TradeIntent = .buy,
        neededAt: Date = Date(),
        productDescription: String = "",
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
        self.quantityUnit = quantityUnit
        self.targetMarket = targetMarket
        self.tradeIntent = tradeIntent
        self.neededAt = neededAt
        self.productDescription = productDescription
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
