import SwiftUI

@main
struct WimbledonApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FontRegistrar.registerFonts()          // Montserrat (alternativa libre de Gotham, tipografía del logo)
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(authViewModel)
                .tint(WimbledonTheme.purple)
                .preferredColorScheme(.light)  // Identidad "all-white" de Wimbledon
        }
    }
}
