//
//  MessageBanner.swift
//  Banner de error (rojo) o de éxito (verde Wimbledon).
//

import SwiftUI

struct MessageBanner: View {
    enum Kind { case error, success }

    let message: String
    let kind: Kind

    private var color: Color { kind == .error ? WimbledonTheme.errorRed : WimbledonTheme.green }
    private var icon: String { kind == .error ? "exclamationmark.triangle.fill" : "checkmark.seal.fill" }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
            Text(message)
                .font(WimbledonFont.medium(14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(color)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.1))
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
