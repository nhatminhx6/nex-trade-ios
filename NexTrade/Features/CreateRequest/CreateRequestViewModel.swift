import Foundation

@MainActor
final class CreateRequestViewModel: ObservableObject {
    @Published var productName = ""
    @Published var category = "category.fruit"
    @Published var quantity = ""
    @Published var targetMarket = ""
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
    private let service: SourcingRequestServiceProtocol

    enum Field: Hashable {
        case productName
        case category
        case contactPhone
        case contactEmail
    }

    init(service: SourcingRequestServiceProtocol) {
        self.service = service
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
            productName: productName.trimmed,
            category: category.trimmed,
            quantity: quantity.trimmed,
            targetMarket: targetMarket.trimmed,
            budget: budget.trimmed,
            note: note.trimmed,
            contactName: contactName.trimmed,
            contactPhone: contactPhone.trimmed,
            contactEmail: contactEmail.trimmed
        )

        do {
            try await service.submitRequest(request)
            didSubmit = true
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

        return true
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
