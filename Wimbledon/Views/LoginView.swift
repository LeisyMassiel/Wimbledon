//
//  LoginView.swift
//  2. LOGIN (estilo myWimbledon)
//  • Campos: email y contraseña (SecureField + ojito)
//  • Botón deshabilitado si los campos están vacíos (.disabled)
//  • Validación en LoginViewModel, error reactivo (@Published)
//  • Enlace "¿No tienes cuenta? Regístrate" → Registro
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ── Logo arriba
                WimbledonLogoView(size: 110)
                    .padding(.top, 32)
                    .padding(.bottom, 24)

                // ── Título verde
                Text("Inicia sesión en Wimbledon")
                    .font(WimbledonFont.semibold(20))
                    .foregroundStyle(WimbledonTheme.green)
                    .padding(.bottom, 28)

                // ── Campos
                VStack(alignment: .leading, spacing: 20) {
                    WimbledonInputField(label: "Correo electrónico",
                                        text: $viewModel.email,
                                        keyboard: .emailAddress,
                                        contentType: .emailAddress)

                    VStack(alignment: .leading, spacing: 8) {
                        WimbledonInputField(label: "Contraseña",
                                            text: $viewModel.password,
                                            isSecure: true,
                                            contentType: .password)

                        Text("Mínimo 6 caracteres, 1 mayúscula y 1 carácter especial (sin . , ; ni tildes).")
                            .font(WimbledonFont.regular(12))
                            .foregroundStyle(WimbledonTheme.secondaryText)
                    }
                }

                // ── Error reactivo desde el ViewModel
                if let error = viewModel.errorMessage {
                    MessageBanner(message: error, kind: .error)
                        .padding(.top, 20)
                }

                // ── Botón verde (deshabilitado si hay campos vacíos)
                Button("Iniciar sesión") {
                    viewModel.login(using: authViewModel)
                }
                .buttonStyle(WimbledonButtonStyle())
                .disabled(viewModel.isFormEmpty)
                .padding(.top, 28)

                // ── Enlace al registro
                NavigationLink {
                    RegisterView()
                } label: {
                    Text("¿No tienes cuenta? Regístrate")
                        .font(WimbledonFont.semibold(16))
                        .foregroundStyle(WimbledonTheme.green)
                        .underline()
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.25), value: viewModel.errorMessage)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(WimbledonTheme.white)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack { LoginView() }
        .environmentObject(AuthViewModel())
}
