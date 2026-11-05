//
//  WimbledonButtonStyle.swift
//  Botón principal verde Wimbledon (#006633), texto en mayúsculas.
//  Cuando está .disabled se ve atenuado.
//

import SwiftUI

struct WimbledonButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(WimbledonFont.bold(15))
            .textCase(.uppercase)
            .tracking(0.5)
            .foregroundStyle(WimbledonTheme.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(WimbledonTheme.green)
            )
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
