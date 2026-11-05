import SwiftUI
import UIKit

enum AppTab: Hashable {
    case home
    case profile
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
    
        ZStack {
            HomeView()
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .accessibilityHidden(selectedTab != .home)

            ProfileView()
                .opacity(selectedTab == .profile ? 1 : 0)
                .allowsHitTesting(selectedTab == .profile)
                .accessibilityHidden(selectedTab != .profile)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            WimbledonTabBar(selected: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)   // la barra no sube con el teclado
    }
}

// MARK: - Barra inferior

struct WimbledonTabBar: View {
    @Binding var selected: AppTab

    private let activeColor = WimbledonTheme.purple
    private let inactiveColor = Color.black.opacity(0.55)

    var body: some View {
        HStack(spacing: 0) {
            // Inicio → logo de Wimbledon (gris inactivo / a color activo)
            TabBarItem(title: "Inicio",
                       isSelected: selected == .home,
                       activeColor: activeColor,
                       inactiveColor: inactiveColor) {
                selected = .home
            } icon: { isSelected in
                if let logo = UIImage(named: "logo") {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .saturation(isSelected ? 1 : 0)
                        .opacity(isSelected ? 1 : 0.6)
                } else {
                    Image(systemName: "house")
                        .font(.system(size: 24, weight: .light))
                }
            }

            // Perfil → ícono de persona de línea fina
            TabBarItem(title: "Perfil",
                       isSelected: selected == .profile,
                       activeColor: activeColor,
                       inactiveColor: inactiveColor) {
                selected = .profile
            } icon: { _ in
                Image(systemName: "person")
                    .font(.system(size: 25, weight: .light))
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            WimbledonTheme.white
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: .black.opacity(0.06), radius: 6, y: -2)
        )
    }
}

private struct TabBarItem<Icon: View>: View {
    let title: String
    let isSelected: Bool
    let activeColor: Color
    let inactiveColor: Color
    let action: () -> Void
    @ViewBuilder let icon: (Bool) -> Icon

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                icon(isSelected)
                    .frame(height: 30)
                Text(title)
                    .font(WimbledonFont.medium(14))
            }
            .foregroundStyle(isSelected ? activeColor : inactiveColor)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
