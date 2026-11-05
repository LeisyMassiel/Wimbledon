//
//  LoginViewModel.swift
//  Toda la validación del Login vive aquí (no en la vista).
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    // Campos enlazados con $ desde la vista. Al escribir se limpia el error.
    @Published var email = "" { didSet { if errorMessage != nil { errorMessage = nil } } }
    @Published var password = "" { didSet { if errorMessage != nil { errorMessage = nil } } }

    /// Mensaje de error que la vista muestra reactivamente.
    @Published var errorMessage: String?

    /// Datos válidos guardados de forma TEMPORAL (solo mientras vive el ViewModel).
    private(set) var validatedEmail: String?
    private(set) var validatedPassword: String?

    /// Controla el .disabled del botón.
    var isFormEmpty: Bool {
        email.trimmed.isEmpty || password.isEmpty
    }

    /// Valida formato de email y reglas de contraseña. Devuelve true si todo es correcto.
    func validate() -> Bool {
        let cleanEmail = email.trimmed

        guard Validator.isValidEmail(cleanEmail) else {
            errorMessage = "Ingresa un correo electrónico con formato válido (ej. nombre@dominio.com)."
            return false
        }
        if let passwordError = Validator.passwordError(password) {
            errorMessage = passwordError
            return false
        }

        // Datos válidos → se guardan temporalmente en variables
        validatedEmail = cleanEmail
        validatedPassword = password
        errorMessage = nil
        return true
    }

    func login(using auth: AuthViewModel) {
        guard validate(), let email = validatedEmail, let password = validatedPassword else { return }

        guard let user = auth.authenticate(email: email, password: password) else {
            errorMessage = "Correo o contraseña incorrectos. Si aún no tienes cuenta, regístrate."
            return
        }
        auth.signIn(user)
    }
}
