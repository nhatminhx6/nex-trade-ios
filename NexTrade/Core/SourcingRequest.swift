import Foundation

struct SourcingRequest: Identifiable, Hashable {
    let id: UUID
    let productName: String
    let category: String
    let quantity: String
    let targetMarket: String
    let budget: String
    let note: String
    let contactName: String
    let contactPhone: String
    let contactEmail: String
    let status: SourcingRequestStatus
    let adminNote: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        productName: String,
        category: String,
        quantity: String,
        targetMarket: String,
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
