//
//  AuthViewModel.swift
//  ViewModel COMPARTIDO de sesión. Se inyecta como @EnvironmentObject.
//  Guarda en memoria la lista de usuarios registrados y el usuario autenticado.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    /// Usuarios registrados (solo en memoria).
    @Published private(set) var users: [User] = [User.demo]

    /// Usuario con sesión iniciada. nil = sin sesión → se muestra el Login.
    @Published private(set) var currentUser: User?

    // MARK: Consultas
    func emailExists(_ email: String) -> Bool {
        users.contains { $0.email.lowercased() == email.trimmed.lowercased() }
    }

    func authenticate(email: String, password: String) -> User? {
        users.first { $0.email.lowercased() == email.trimmed.lowercased() && $0.password == password }
    }

    // MARK: Acciones
    func register(_ user: User) {
        users.append(user)
    }

    func signIn(_ user: User) {
        currentUser = user
    }

    /// Limpia el usuario autenticado → AppFlowView vuelve a mostrar el Login.
    func logout() {
        currentUser = nil
    }
}
