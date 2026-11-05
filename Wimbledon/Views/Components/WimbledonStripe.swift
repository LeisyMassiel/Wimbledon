//
//  WimbledonStripe.swift
//  Doble franja verde/púrpura: el recurso gráfico del torneo
//  (es justamente la combinación de colores registrada como marca).
//

import SwiftUI

struct WimbledonStripe: View {
    var height: CGFloat = 4

    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(WimbledonTheme.green).frame(height: height)
            Rectangle().fill(WimbledonTheme.purple).frame(height: height)
        }
        .accessibilityHidden(true)
    }
}
