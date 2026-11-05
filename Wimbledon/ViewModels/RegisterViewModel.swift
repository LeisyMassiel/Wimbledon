//
//  RegisterViewModel.swift
//  Validación del registro + guardado del usuario en el AuthViewModel compartido.
//

import Foundation

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var name = ""            { didSet { clearError() } }
    @Published var email = ""           { didSet { clearError() } }
    @Published var password = ""        { didSet { clearError() } }
    @Published var confirmPassword = "" { didSet { clearError() } }

    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published private(set) var isSubmitting = false

    var isButtonDisabled: Bool { isSubmitting || successMessage != nil }

    private func clearError() {
        if errorMessage != nil { errorMessage = nil }
    }

    func validate(against auth: AuthViewModel) -> Bool {
        // 1. Ningún campo vacío
        guard !name.trimmed.isEmpty,
              !email.trimmed.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            errorMessage = "Completa todos los campos."
            return false
        }
        // 2. Email con formato válido
        guard Validator.isValidEmail(email.trimmed) else {
            errorMessage = "Ingresa un correo electrónico con formato válido."
            return false
        }
        // 3. Email único (se verifica contra la lista en memoria)
        guard !auth.emailExists(email) else {
            errorMessage = "Ya existe una cuenta con ese correo electrónico."
            return false
        }
        // 4. Mismas reglas de contraseña que el Login (si no, el usuario no podría entrar luego)
        if let passwordError = Validator.passwordError(password) {
            errorMessage = passwordError
            return false
        }
        // 5. Las contraseñas coinciden
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden."
            return false
        }
        return true
    }

    func register(using auth: AuthViewModel) async {
        guard validate(against: auth) else { return }
        isSubmitting = true

        let user = User(name: name.trimmed, email: email.trimmed.lowercased(), password: password)
        auth.register(user)                                    // se almacena en el EnvironmentObject

        successMessage = "¡Cuenta creada! Bienvenido a The Championships, \(user.name)."
        try? await Task.sleep(for: .seconds(1.5))              // feedback visual antes de navegar

        auth.signIn(user)                                      // AppFlowView navega al Home
        isSubmitting = false
    }
}
