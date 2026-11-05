import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showLogoutConfirm = false

    private let pageBackground = Color(red: 0.965, green: 0.969, blue: 0.976)

    private var user: User? { authViewModel.currentUser }

    private var initials: String {
        (user?.name ?? "")
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Encabezado fijo
            HStack {
                Text("Perfil")
                    .font(WimbledonFont.bold(20))
                    .foregroundStyle(.black)
                Spacer()
                WimbledonLogoView(size: 28)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(pageBackground)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // ── Tarjeta del usuario
                    VStack(spacing: 8) {
                        Circle()
                            .fill(WimbledonTheme.green)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Text(initials)
                                    .font(WimbledonFont.bold(20))
                                    .foregroundStyle(WimbledonTheme.white)
                            )
                        Text(user?.name ?? "")
                            .font(WimbledonFont.semibold(16))
                            .foregroundStyle(.black)
                        Text(user?.email ?? "")
                            .font(WimbledonFont.regular(12))
                            .foregroundStyle(WimbledonTheme.secondaryText)
                        WimbledonStripe(height: 1.5)
                            .frame(width: 50)
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(card)

                    // ── Datos de la cuenta
                    VStack(alignment: .leading, spacing: 0) {
                        Text("MI CUENTA")
                            .font(.system(size: 12, weight: .regular, design: .serif))
                            .tracking(0.8)
                            .foregroundStyle(WimbledonTheme.purple)
                            .padding(.bottom, 2)

                        ProfileRow(label: "Nombre", value: user?.name ?? "")
                        ProfileRow(label: "Correo electrónico", value: user?.email ?? "")
                        ProfileRow(label: "Torneo", value: "The Championships, Wimbledon")
                        ProfileRow(label: "Sede", value: "All England Lawn Tennis & Croquet Club", showDivider: false)
                    }
                    .padding(14)
                    .background(card)
                    .padding(.top, 12)

                    // ── Cerrar sesión (púrpura, con la flechita del Home)
                    Button {
                        showLogoutConfirm = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 14, weight: .regular))
                            Text("Cerrar sesión")
                                .font(WimbledonFont.semibold(14))
                        }
                        .foregroundStyle(WimbledonTheme.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(WimbledonTheme.purple)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 20)

                    
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
        }
        .background(pageBackground.ignoresSafeArea())
        .confirmationDialog("¿Quieres cerrar sesión?",
                            isPresented: $showLogoutConfirm,
                            titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) {
                authViewModel.logout()        // limpia el usuario → vuelve al Login
            }
            Button("Cancelar", role: .cancel) { }
        }
    }

    private var card: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(WimbledonTheme.white)
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.12), lineWidth: 1)
            )
    }
}

private struct ProfileRow: View {
    let label: String
    let value: String
    var showDivider: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(label)
                    .font(WimbledonFont.regular(13))
                    .foregroundStyle(WimbledonTheme.secondaryText)
                Spacer(minLength: 12)
                Text(value)
                    .font(WimbledonFont.medium(13))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 10)
            if showDivider { Divider() }
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    auth.signIn(.demo)
    return ProfileView().environmentObject(auth)
}
