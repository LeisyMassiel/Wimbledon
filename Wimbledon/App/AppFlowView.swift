import SwiftUI

struct AppFlowView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.currentUser != nil {
                MainTabView()
                    .transition(.opacity)
            } else {
                NavigationStack {
                    LoginView()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: authViewModel.currentUser?.id)
    }
}
