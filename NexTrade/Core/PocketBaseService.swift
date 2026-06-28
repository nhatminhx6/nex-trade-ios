import Foundation

actor PocketBaseService: SourcingRequestServiceProtocol, AuthenticationServiceProtocol, ApprovedListingServiceProtocol {
    private let baseURL: URL
    private let session: URLSession
    private var authSession: AuthSession?

    init(
        baseURL: URL? = nil,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL ?? APIConfiguration.baseURL
        self.session = session
        self.authSession = KeychainStore.load()
    }

    func restoreSession() async -> AuthSession? {
        authSession
    }

    func login(email: String, password: String) async throws -> AppUser {
        struct LoginPayload: Encodable { let identity: String; let password: String }
        let response: AuthResponse = try await request(
            path: "collections/users/auth-with-password",
            method: "POST",
            body: LoginPayload(identity: email, password: password),
            authenticated: false
        )
        let session = AuthSession(token: response.token, user: response.record.appUser)
        try KeychainStore.save(session)
        authSession = session
        return session.user
    }

    func logout() async {
        authSession = nil
        KeychainStore.delete()
    }

    func submitRequest(_ sourcingRequest: SourcingRequest) async throws {
        guard let user = authSession?.user else { throw APIError.unauthenticated }
        try await updateProfile(for: user, with: sourcingRequest)

        let payload = CreateRequestPayload(
            request: sourcingRequest,
            apiCategory: Self.apiCategory(for: sourcingRequest.category),
            neededAt: Self.tradeDateFormatter.string(from: sourcingRequest.neededAt),
            status: "submitted",
            createdBy: user.id
        )
        try await perform(path: "collections/sourcing_requests/records", method: "POST", body: payload)
    }

    func updateRequest(_ sourcingRequest: SourcingRequest) async throws {
        guard let user = authSession?.user else { throw APIError.unauthenticated }
        try await updateProfile(for: user, with: sourcingRequest)

        let payload = UpdateRequestPayload(
            request: sourcingRequest,
            apiCategory: Self.apiCategory(for: sourcingRequest.category),
            neededAt: Self.tradeDateFormatter.string(from: sourcingRequest.neededAt)
        )
        try await perform(path: "collections/sourcing_requests/records/\(sourcingRequest.id)", method: "PATCH", body: payload)
        try? await removeApprovedListings(for: sourcingRequest.id)
    }

    func deleteRequest(id: String) async throws {
        guard authSession?.user != nil else { throw APIError.unauthenticated }
        try await perform(path: "collections/sourcing_requests/records/\(id)", method: "DELETE", body: Optional<EmptyRequestBody>.none)
    }

    func fetchRequests() async throws -> [SourcingRequest] {
        struct ListResponse: Decodable { let items: [RequestRecord] }
        let response: ListResponse = try await request(path: "collections/sourcing_requests/records")
        let user = authSession?.user
        return response.items.map { $0.sourcingRequest(contact: user) }
    }

    func fetchRequest(id: String) async throws -> SourcingRequest? {
        let record: RequestRecord = try await request(path: "collections/sourcing_requests/records/\(id)")
        return record.sourcingRequest(contact: authSession?.user)
    }

    func fetchApprovedListings() async throws -> [ApprovedListing] {
        struct ListResponse: Decodable { let items: [ListingRecord] }
        let response: ListResponse = try await request(path: "collections/approved_listings/records")
        return response.items.map(\.approvedListing)
    }

    private func removeApprovedListings(for requestID: String) async throws {
        struct ListResponse: Decodable { let items: [ListingRecord] }
        let filter = "request='\(requestID)'".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let response: ListResponse = try await request(path: "collections/approved_listings/records?filter=\(filter)&perPage=50")

        for listing in response.items {
            try await perform(path: "collections/approved_listings/records/\(listing.id)", method: "DELETE", body: Optional<EmptyRequestBody>.none)
        }
    }

    private func updateProfile(for user: AppUser, with sourcingRequest: SourcingRequest) async throws {
        let name = sourcingRequest.contactName.isEmpty ? user.name : sourcingRequest.contactName
        let phone = sourcingRequest.contactPhone.isEmpty ? user.phone : sourcingRequest.contactPhone
        struct ProfilePayload: Encodable { let name: String; let phone: String }
        try await perform(
            path: "collections/users/records/\(user.id)",
            method: "PATCH",
            body: ProfilePayload(name: name, phone: phone)
        )
        guard let activeSession = authSession else { return }
        let updated = AppUser(id: user.id, email: user.email, name: name, phone: phone, companyName: user.companyName, role: user.role)
        let session = AuthSession(token: activeSession.token, user: updated)
        try KeychainStore.save(session)
        authSession = session
    }

    private func request<Response: Decodable, Body: Encodable>(path: String, method: String = "GET", body: Body? = nil, authenticated: Bool = true) async throws -> Response {
        let data = try await perform(path: path, method: method, body: body, authenticated: authenticated)
        return try JSONDecoder.pocketBase.decode(Response.self, from: data)
    }

    @discardableResult
    private func perform<Body: Encodable>(path: String, method: String = "GET", body: Body? = nil, authenticated: Bool = true) async throws -> Data {
        guard let url = URL(string: path, relativeTo: baseURL)?.absoluteURL else { throw APIError.invalidURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if authenticated, let token = authSession?.token {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body { urlRequest.httpBody = try JSONEncoder().encode(body) }
        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else { throw APIError.server(statusCode: http.statusCode) }
        return data
    }

    private func request<Response: Decodable>(path: String, method: String = "GET") async throws -> Response {
        return try await request(path: path, method: method, body: Optional<EmptyRequestBody>.none)
    }

    private static func apiCategory(for category: String) -> String {
        switch category {
        case "category.fruit": "fruit"
        case "category.vegetables": "vegetable"
        case "category.dryFood", "category.beverage": "other"
        default: "other"
        }
    }

    fileprivate static let tradeDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

private struct EmptyRequestBody: Encodable {}

private struct CreateRequestPayload: Encodable {
    let title: String
    let productName: String
    let category: String
    let quantity: String
    let quantityUnit: String
    let targetCountry: String
    let tradeIntent: String
    let neededAt: String
    let productDescription: String
    let budgetRange: String
    let description: String
    let contactName: String
    let contactPhone: String
    let contactEmail: String
    let status: String
    let createdBy: String

    init(request: SourcingRequest, apiCategory: String, neededAt: String, status: String, createdBy: String) {
        title = request.productName
        productName = request.productName
        category = apiCategory
        quantity = request.quantity
        quantityUnit = request.quantityUnit
        targetCountry = request.targetMarket
        tradeIntent = request.tradeIntent.rawValue
        self.neededAt = neededAt
        productDescription = request.productDescription
        budgetRange = request.budget
        description = request.note
        contactName = request.contactName
        contactPhone = request.contactPhone
        contactEmail = request.contactEmail
        self.status = status
        self.createdBy = createdBy
    }

    enum CodingKeys: String, CodingKey {
        case title, category, quantity, status
        case quantityUnit = "quantity_unit"
        case productName = "product_name"
        case targetCountry = "target_country"
        case tradeIntent = "trade_intent"
        case neededAt = "needed_at"
        case productDescription = "product_description"
        case budgetRange = "budget_range"
        case description
        case contactName = "contact_name"
        case contactPhone = "contact_phone"
        case contactEmail = "contact_email"
        case createdBy = "created_by"
    }
}

private struct UpdateRequestPayload: Encodable {
    let title: String
    let productName: String
    let category: String
    let quantity: String
    let quantityUnit: String
    let targetCountry: String
    let tradeIntent: String
    let neededAt: String
    let productDescription: String
    let budgetRange: String
    let description: String
    let contactName: String
    let contactPhone: String
    let contactEmail: String
    let status: String

    init(request: SourcingRequest, apiCategory: String, neededAt: String) {
        title = request.productName
        productName = request.productName
        category = apiCategory
        quantity = request.quantity
        quantityUnit = request.quantityUnit
        targetCountry = request.targetMarket
        tradeIntent = request.tradeIntent.rawValue
        self.neededAt = neededAt
        productDescription = request.productDescription
        budgetRange = request.budget
        description = request.note
        contactName = request.contactName
        contactPhone = request.contactPhone
        contactEmail = request.contactEmail
        status = "submitted"
    }

    enum CodingKeys: String, CodingKey {
        case title, category, quantity, status
        case quantityUnit = "quantity_unit"
        case productName = "product_name"
        case targetCountry = "target_country"
        case tradeIntent = "trade_intent"
        case neededAt = "needed_at"
        case productDescription = "product_description"
        case budgetRange = "budget_range"
        case description
        case contactName = "contact_name"
        case contactPhone = "contact_phone"
        case contactEmail = "contact_email"
    }
}

private enum APIConfiguration {
    static var baseURL: URL {
        let configuredValue = Bundle.main.object(forInfoDictionaryKey: "NexTradeAPIBaseURL") as? String
        let value = configuredValue ?? "http://127.0.0.1:8090/api/"
        let normalizedValue = value.hasSuffix("/") ? value : "\(value)/"
        return URL(string: normalizedValue) ?? URL(string: "http://127.0.0.1:8090/api/")!
    }
}

enum APIError: LocalizedError {
    case unauthenticated, invalidURL, invalidResponse, server(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .unauthenticated: "Please sign in to continue."
        case .invalidURL, .invalidResponse, .server: "The server could not complete this request."
        }
    }

    var messageKey: String {
        switch self {
        case .unauthenticated, .server(statusCode: 401):
            "error.session"
        case .server(statusCode: 403):
            "error.permission"
        case .server(statusCode: 400):
            "error.request.invalid"
        case .invalidURL, .invalidResponse, .server:
            "error.submit"
        }
    }
}

private struct AuthResponse: Decodable {
    let token: String
    let record: UserRecord
}

private struct UserRecord: Decodable {
    let id: String
    let email: String
    let name: String?
    let phone: String?
    let companyName: String?
    let role: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name, phone, role
        case companyName = "company_name"
    }

    var appUser: AppUser {
        AppUser(id: id, email: email, name: name ?? "", phone: phone ?? "", companyName: companyName ?? "", role: role ?? "buyer")
    }
}

private struct RequestRecord: Decodable {
    let id: String
    let productName: String
    let category: String
    let quantity: String?
    let quantityUnit: String?
    let targetCountry: String?
    let tradeIntent: String?
    let neededAt: String?
    let productDescription: String?
    let budgetRange: String?
    let description: String?
    let contactName: String?
    let contactPhone: String?
    let contactEmail: String?
    let status: String?
    let created: Date?

    enum CodingKeys: String, CodingKey {
        case id, category, quantity, description, status, created
        case quantityUnit = "quantity_unit"
        case contactName = "contact_name"
        case contactPhone = "contact_phone"
        case contactEmail = "contact_email"
        case productName = "product_name"
        case targetCountry = "target_country"
        case tradeIntent = "trade_intent"
        case neededAt = "needed_at"
        case productDescription = "product_description"
        case budgetRange = "budget_range"
    }

    func sourcingRequest(contact: AppUser?) -> SourcingRequest {
        SourcingRequest(
            id: id,
            productName: productName,
            category: Self.appCategory(for: category),
            quantity: quantity ?? "",
            quantityUnit: quantityUnit ?? "kg",
            targetMarket: targetCountry ?? "",
            tradeIntent: TradeIntent(rawValue: tradeIntent ?? "buy") ?? .buy,
            neededAt: Self.tradeDate(from: neededAt) ?? Date(),
            productDescription: productDescription ?? "",
            budget: budgetRange ?? "",
            note: description ?? "",
            contactName: contactName ?? contact?.name ?? "",
            contactPhone: contactPhone ?? contact?.phone ?? "",
            contactEmail: contactEmail ?? contact?.email ?? "",
            status: SourcingRequestStatus(apiStatus: status),
            createdAt: created ?? .distantPast
        )
    }

    private static func appCategory(for category: String) -> String {
        switch category {
        case "fruit": "category.fruit"
        case "vegetable": "category.vegetables"
        case "other": "category.other"
        default: "category.other"
        }
    }

    fileprivate static func tradeDate(from value: String?) -> Date? {
        guard let value else { return nil }
        return PocketBaseService.tradeDateFormatter.date(from: value)
    }
}

private struct ListingRecord: Decodable {
    let id: String
    let title: String
    let productName: String
    let category: String?
    let quantity: String?
    let quantityUnit: String?
    let targetCountry: String?
    let tradeIntent: String?
    let neededAt: String?
    let publishedAt: String?
    let productDescription: String?
    let budgetRange: String?
    let description: String?
    let created: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, category, quantity, description, created
        case quantityUnit = "quantity_unit"
        case productName = "product_name"
        case targetCountry = "target_country"
        case tradeIntent = "trade_intent"
        case neededAt = "needed_at"
        case publishedAt = "published_at"
        case productDescription = "product_description"
        case budgetRange = "budget_range"
    }

    var approvedListing: ApprovedListing {
        ApprovedListing(id: id, title: title, productName: productName, category: category ?? "other", quantity: quantity ?? "", quantityUnit: quantityUnit ?? "kg", targetMarket: targetCountry ?? "", tradeIntent: TradeIntent(rawValue: tradeIntent ?? "buy") ?? .buy, neededAt: RequestRecord.tradeDate(from: neededAt), publishedAt: RequestRecord.tradeDate(from: publishedAt), productDescription: productDescription ?? "", budget: budgetRange ?? "", description: description ?? "", createdAt: created ?? .distantPast)
    }
}

private extension SourcingRequestStatus {
    init(apiStatus: String?) {
        switch apiStatus {
        case "submitted":
            self = .new
        case "reviewing", "sourcing": self = .reviewing
        case "quoted": self = .quoted
        case "approved": self = .approved
        case "rejected": self = .rejected
        case "completed": self = .completed
        case "cancelled": self = .cancelled
        default: self = .new
        }
    }
}

private extension JSONDecoder {
    static let pocketBase: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let value = try decoder.singleValueContainer().decode(String.self)
            if let date = formatter.date(from: value) { return date }
            let normalizedValue = value.replacingOccurrences(of: " ", with: "T")
            if let date = formatter.date(from: normalizedValue) { return date }
            let container = try decoder.singleValueContainer()
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid PocketBase date")
        }
        return decoder
    }()
}
