import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ── Barra superior: flecha volver (izquierda) + logo
                ZStack(alignment: .topLeading) {
                    WimbledonLogoView(size: 90)
                        .frame(maxWidth: .infinity)

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(.black)
                            .frame(width: 44, height: 44, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Volver")
                }
                .padding(.top, 16)
                .padding(.bottom, 20)

                // ── Título verde
                Text("Únete a Wimbledon")
                    .font(WimbledonFont.semibold(20))
                    .foregroundStyle(WimbledonTheme.green)
                    .padding(.bottom, 24)

                // ── Campos
                VStack(alignment: .leading, spacing: 20) {
                    WimbledonInputField(label: "Nombre",
                                        text: $viewModel.name,
                                        contentType: .name,
                                        autocapitalize: true)

                    WimbledonInputField(label: "Correo electrónico",
                                        text: $viewModel.email,
                                        keyboard: .emailAddress,
                                        contentType: .emailAddress)

                    // Contraseña y confirmación lado a lado
                    HStack(alignment: .top, spacing: 12) {
                        WimbledonInputField(label: "Contraseña",
                                            text: $viewModel.password,
                                            isSecure: true,
                                            contentType: .newPassword)

                        WimbledonInputField(label: "Confirmar contraseña",
                                            text: $viewModel.confirmPassword,
                                            isSecure: true,
                                            contentType: .newPassword)
                    }

                    Text("Mínimo 6 caracteres, 1 mayúscula y 1 carácter especial (sin . , ; ni tildes).")
                        .font(WimbledonFont.regular(12))
                        .foregroundStyle(WimbledonTheme.secondaryText)
                        .padding(.top, -12)
                }

                // ── Mensajes (error / éxito)
                if let error = viewModel.errorMessage {
                    MessageBanner(message: error, kind: .error)
                        .padding(.top, 20)
                }
                if let success = viewModel.successMessage {
                    MessageBanner(message: success, kind: .success)
                        .padding(.top, 20)
                }

                // ── Botón verde
                Button {
                    Task { await viewModel.register(using: authViewModel) }
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView().tint(WimbledonTheme.white)
                    } else {
                        Text("Crear cuenta")
                    }
                }
                .buttonStyle(WimbledonButtonStyle())
                .disabled(viewModel.isButtonDisabled)
                .padding(.top, 28)

                // ── Volver al login
                Button {
                    dismiss()
                } label: {
                    Text("¿Ya tienes cuenta? Inicia sesión")
                        .font(WimbledonFont.semibold(16))
                        .foregroundStyle(WimbledonTheme.green)
                        .underline()
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.25), value: viewModel.errorMessage)
            .animation(.easeInOut(duration: 0.25), value: viewModel.successMessage)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(WimbledonTheme.white)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack { RegisterView() }
        .environmentObject(AuthViewModel())
}
