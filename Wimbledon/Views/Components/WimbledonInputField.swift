//
//  WimbledonInputField.swift
//  Campo estilo myWimbledon: etiqueta arriba, caja blanca con borde gris
//  que se vuelve más oscuro y grueso cuando el campo está activo (@FocusState).
//  isSecure = true → SecureField con ojito para mostrar/ocultar.
//

import SwiftUI
import UIKit

struct WimbledonInputField: View {
    let label: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    var autocapitalize: Bool = false

    @FocusState private var isFocused: Bool
    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Etiqueta arriba: "Correo electrónico *"
            Text("\(label) *")
                .font(WimbledonFont.semibold(15))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            HStack(spacing: 8) {
                Group {
                    if isSecure && !isRevealed {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                            .keyboardType(isSecure ? .default : keyboard)
                    }
                }
                .focused($isFocused)
                .font(WimbledonFont.regular(16))
                .foregroundStyle(.black)
                .textContentType(contentType)
                .textInputAutocapitalization(autocapitalize ? .words : .never)
                .autocorrectionDisabled()

                // Ojito solo en contraseña
                if isSecure {
                    Button {
                        isRevealed.toggle()
                        isFocused = true
                    } label: {
                        Image(systemName: isRevealed ? "eye.slash" : "eye")
                            .font(.system(size: 18))
                            .foregroundStyle(.black.opacity(0.75))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isRevealed ? "Ocultar contraseña" : "Mostrar contraseña")
                }
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(WimbledonTheme.white)
            )
            // Borde: gris fino normal → oscuro y grueso cuando está activo
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(isFocused ? Color.black.opacity(0.85) : Color.black.opacity(0.25),
                                  lineWidth: isFocused ? 2 : 1)
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }
        }
    }
}
