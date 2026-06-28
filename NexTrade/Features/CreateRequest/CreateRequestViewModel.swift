import Foundation

@MainActor
final class CreateRequestViewModel: ObservableObject {
    @Published var productName = ""
    @Published var category = "category.fruit"
    @Published var quantity = ""
    @Published var quantityUnit = "kg"
    @Published var targetMarket = ""
    @Published var tradeIntent: TradeIntent = .buy
    @Published var neededAt = Date()
    @Published var productDescription = ""
    @Published var budget = ""
    @Published var note = ""
    @Published var contactName = ""
    @Published var contactPhone = ""
    @Published var contactEmail = ""
    @Published var errorMessageKey: String?
    @Published var fieldErrorKeys: [Field: String] = [:]
    @Published var isSubmitting = false
    @Published var didSubmit = false

    let categories = ["category.fruit", "category.vegetables", "category.dryFood", "category.beverage", "category.other"]
    let quantityUnits = ["kg", "ton", "container", "carton", "piece"]
    let editingRequest: SourcingRequest?
    private let service: SourcingRequestServiceProtocol

    var isEditing: Bool {
        editingRequest != nil
    }

    enum Field: Hashable {
        case productName
        case category
        case contactPhone
        case contactEmail
    }

    init(service: SourcingRequestServiceProtocol, currentUser: AppUser? = nil, editingRequest: SourcingRequest? = nil) {
        self.service = service
        self.editingRequest = editingRequest

        if let editingRequest {
            productName = editingRequest.productName
            category = editingRequest.category
            quantity = editingRequest.quantity
            quantityUnit = editingRequest.quantityUnit
            targetMarket = editingRequest.targetMarket
            tradeIntent = editingRequest.tradeIntent
            neededAt = editingRequest.neededAt
            productDescription = editingRequest.productDescription
            budget = editingRequest.budget
            note = editingRequest.note
            contactName = editingRequest.contactName
            contactPhone = editingRequest.contactPhone
            contactEmail = editingRequest.contactEmail
        } else {
            contactName = currentUser?.name ?? ""
            contactPhone = currentUser?.phone ?? ""
            contactEmail = currentUser?.email ?? ""
        }
    }

    func prefillContact(from user: AppUser) {
        if contactName.trimmed.isEmpty { contactName = user.name }
        if contactPhone.trimmed.isEmpty { contactPhone = user.phone }
        if contactEmail.trimmed.isEmpty { contactEmail = user.email }
    }

    func submit() async {
        errorMessageKey = nil
        fieldErrorKeys = [:]

        guard validate() else {
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let request = SourcingRequest(
            id: editingRequest?.id ?? UUID().uuidString,
            productName: productName.trimmed,
            category: category.trimmed,
            quantity: quantity.trimmed,
            quantityUnit: quantityUnit,
            targetMarket: targetMarket.trimmed,
            tradeIntent: tradeIntent,
            neededAt: Calendar.current.startOfDay(for: neededAt),
            productDescription: productDescription.trimmed,
            budget: budget.trimmed,
            note: note.trimmed,
            contactName: contactName.trimmed,
            contactPhone: contactPhone.trimmed,
            contactEmail: contactEmail.trimmed,
            status: isEditing ? .new : (editingRequest?.status ?? .new),
            adminNote: editingRequest?.adminNote,
            createdAt: editingRequest?.createdAt ?? Date()
        )

        do {
            if isEditing {
                try await service.updateRequest(request)
            } else {
                try await service.submitRequest(request)
            }
            didSubmit = true
        } catch let error as APIError {
            errorMessageKey = error.messageKey
        } catch {
            errorMessageKey = "error.submit"
        }
    }

    private func validate() -> Bool {
        if productName.trimmed.isEmpty {
            fieldErrorKeys[.productName] = "error.product.required"
            return false
        }

        if category.trimmed.isEmpty {
            fieldErrorKeys[.category] = "error.category.required"
            return false
        }

        if contactPhone.trimmed.isEmpty && contactEmail.trimmed.isEmpty {
            let message = "error.contact.required"
            fieldErrorKeys[.contactPhone] = message
            fieldErrorKeys[.contactEmail] = message
            return false
        }

        if !contactEmail.trimmed.isEmpty && !contactEmail.trimmed.isValidEmail {
            fieldErrorKeys[.contactEmail] = "error.email.invalid"
            return false
        }

        if !contactPhone.trimmed.isEmpty && !contactPhone.trimmed.isValidPhoneNumber {
            fieldErrorKeys[.contactPhone] = "error.phone.invalid"
            return false
        }

        return true
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValidEmail: Bool {
        range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil
    }

    var isValidPhoneNumber: Bool {
        let digits = filter(\.isNumber)
        return digits.count >= 9 && digits.count <= 15
    }
}
