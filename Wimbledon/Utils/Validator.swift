//
//  Validator.swift
//  Reglas de validación compartidas por Login y Registro.
//

import Foundation

enum Validator {

    // MARK: Email
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: Contraseña
    /// Caracteres especiales que SÍ cuentan (no incluye . , ; ni tildes).
    static let allowedSpecialCharacters: Set<Character> = Set("!\"#$%&'()*+-/:<=>?@[\\]_{|}¡¿")

    /// Caracteres que el enunciado excluye: puntos, comas, punto y coma y tildes.
    static let forbiddenCharacters: Set<Character> = Set(".,;´`¨~^áéíóúÁÉÍÓÚàèìòùÀÈÌÒÙäëïöüÄËÏÖÜñÑ")

    /// Devuelve el primer error encontrado o nil si la contraseña es válida.
    static func passwordError(_ password: String) -> String? {
        if password.count < 6 {
            return "La contraseña debe tener al menos 6 caracteres."
        }
        if password.contains(where: { forbiddenCharacters.contains($0) }) {
            return "La contraseña no puede contener puntos, comas, punto y coma ni tildes."
        }
        if !password.contains(where: { $0.isUppercase }) {
            return "La contraseña debe incluir al menos una letra mayúscula."
        }
        if !password.contains(where: { allowedSpecialCharacters.contains($0) }) {
            return "La contraseña debe incluir al menos un carácter especial (por ejemplo # @ ! $ %)."
        }
        return nil
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
