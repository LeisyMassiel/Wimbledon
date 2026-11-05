import Foundation

struct User: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let email: String
    let password: String
}

extension User {
    /// Usuario de prueba precargado para poder iniciar sesión sin registrarse.
    static let demo = User(name: "Invitado", email: "demo@wimbledon.com", password: "Wimbledon#2026")
}
