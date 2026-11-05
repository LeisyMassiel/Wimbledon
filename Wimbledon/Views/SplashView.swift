//
//  SplashView.swift
//  1. SPLASH SCREEN
//  • Logo centrado con animación de entrada (scale + opacity)
//  • Nombre de la app con fuente personalizada (.font)
//  • Navegación automática al Login a los 2 segundos (Task.sleep)
//  • La navegación se controla con @State (Bool local de esta vista)
//

import SwiftUI

struct SplashView: View {
    // ── Navegación: @State porque es un Bool simple, privado y solo de esta vista
    @State private var isActive = false

    // ── Estados de la animación de entrada
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            if isActive {
                AppFlowView()               // → Login (o Home si ya hay sesión)
                    .transition(.opacity)
            } else {
                splashContent
                    .transition(.opacity)
            }
        }
    }

    // MARK: - Contenido del Splash
    private var splashContent: some View {
        ZStack {
            // Fondo blanco (identidad "all-white" de Wimbledon)
            WimbledonTheme.white
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // ── LOGO centrado + animación (scale y opacity)
                WimbledonLogoView(size: 200)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                // ── NOMBRE de la app con fuente personalizada
                VStack(spacing: 8) {
                    Text("WIMBLEDON")
                        .font(WimbledonFont.bold(36))          // ← fuente personalizada vía .font()
                        .tracking(6)
                        .foregroundStyle(WimbledonTheme.purple)

                    Text("The Championships")
                        .font(WimbledonFont.medium(17))
                        .foregroundStyle(WimbledonTheme.green)

                    // Franja verde + púrpura
                    WimbledonStripe(height: 3)
                        .frame(width: 110)
                        .padding(.top, 6)
                }
                .opacity(textOpacity)

                Spacer()

                Text("The All England Lawn Tennis & Croquet Club")
                    .font(WimbledonFont.regular(12))
                    .foregroundStyle(WimbledonTheme.green.opacity(0.8))
                    .opacity(textOpacity)
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
        }
        // ── Se dispara la animación de entrada al aparecer
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1
                logoOpacity = 1
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.4)) {
                textOpacity = 1
            }
        }
        // ── Navegación automática a los 2 segundos
        .task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.4)) {
                isActive = true
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AuthViewModel())
}
