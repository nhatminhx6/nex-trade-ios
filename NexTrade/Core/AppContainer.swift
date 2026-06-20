import SwiftUI

enum AppTab: Hashable {
    case home
    case requests
    case profile
}

@MainActor
final class AppContainer: ObservableObject {
    let sourcingRequestService: SourcingRequestServiceProtocol
    @Published var isDarkMode = false
    @Published var language: AppLanguage = .vietnamese
    @Published var selectedTab: AppTab = .home

    var preferredColorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }

    init(sourcingRequestService: SourcingRequestServiceProtocol = MockSourcingRequestService()) {
        self.sourcingRequestService = sourcingRequestService
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
