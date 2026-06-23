import Foundation

struct AppUser: Codable, Equatable {
    let id: String
    let email: String
    let name: String
    let phone: String
    let companyName: String
    let role: String

    var displayName: String {
        name.isEmpty ? email : name
    }
}

struct AuthSession: Codable {
    let token: String
    let user: AppUser
}

protocol AuthenticationServiceProtocol: AnyObject {
    func restoreSession() async -> AuthSession?
    func login(email: String, password: String) async throws -> AppUser
    func logout() async
}
