import SwiftUI

enum AppTab: Hashable {
    case home
    case discover
    case requests
    case profile
}

@MainActor
final class AppContainer: ObservableObject {
    let sourcingRequestService: SourcingRequestServiceProtocol
    let approvedListingService: ApprovedListingServiceProtocol
    let authenticationService: AuthenticationServiceProtocol
    @Published var isDarkMode = false
    @Published var language: AppLanguage = .vietnamese
    @Published var selectedTab: AppTab = .home
    @Published private(set) var authState: AuthenticationState = .loading
    private let isUITesting: Bool
    private let isUITestingGuest: Bool

    var preferredColorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    var currentUser: AppUser? {
        guard case let .authenticated(user) = authState else { return nil }
        return user
    }

    init(apiService: PocketBaseService = PocketBaseService()) {
        self.sourcingRequestService = apiService
        self.approvedListingService = apiService
        self.authenticationService = apiService
        isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing-authenticated")
        isUITestingGuest = ProcessInfo.processInfo.arguments.contains("-ui-testing-guest")
#if DEBUG
        if isUITesting {
            authState = .authenticated(AppUser(
                id: "ui-test-buyer",
                email: "buyer.demo@nextrade.local",
                name: "UI Test Buyer",
                phone: "0976999864",
                companyName: "NexTrade Test Co.",
                role: "buyer"
            ))
        } else if isUITestingGuest {
            authState = .unauthenticated
        }
#endif
    }

    func toggleDarkMode() {
        isDarkMode.toggle()
    }

    func toggleLanguage() {
        language = language.next
    }

    func t(_ key: String) -> String {
        AppText.values[key]?[language] ?? key
    }

    func restoreSession() async {
        guard !isUITesting else { return }
        guard !isUITestingGuest else {
            authState = .unauthenticated
            return
        }
        if let session = await authenticationService.restoreSession() {
            authState = .authenticated(session.user)
        } else {
            authState = .unauthenticated
        }
    }

    func login(email: String, password: String) async throws {
        let user = try await authenticationService.login(email: email, password: password)
        authState = .authenticated(user)
    }

    func logout() async {
        await authenticationService.logout()
        authState = .unauthenticated
        selectedTab = .home
    }

    func localizedCategory(_ category: String) -> String {
        let key = category.hasPrefix("category.") ? category : categoryKey(for: category)
        return t(key)
    }

    private func categoryKey(for value: String) -> String {
        switch value {
        case "Trái cây", "Fruit":
            "category.fruit"
        case "Rau củ", "Vegetables":
            "category.vegetables"
        case "Thực phẩm khô", "Dry food":
            "category.dryFood"
        case "Đồ uống", "Beverages":
            "category.beverage"
        case "Hàng khác", "Other goods":
            "category.other"
        default:
            value
        }
    }
}

enum AuthenticationState: Equatable {
    case loading
    case unauthenticated
    case authenticated(AppUser)
}
