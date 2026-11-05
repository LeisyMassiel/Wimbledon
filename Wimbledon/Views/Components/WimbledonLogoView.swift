//
//  WimbledonLogoView.swift
//  Muestra el logo oficial (asset "WimbledonLogo") a tamaño completo.
//  El logo de Wimbledon ya es circular, así que no lleva círculo ni margen extra.
//  Si el asset no existe, muestra una raqueta como respaldo.
//

import SwiftUI
import UIKit

struct WimbledonLogoView: View {
    var size: CGFloat = 120

    /// Agranda el dibujo si tu PNG trae bordes transparentes alrededor.
    /// 1.0 = tamaño normal. Prueba 1.1 o 1.2 si aún se ve con margen.
    var zoom: CGFloat = 1.0

    var body: some View {
        Group {
            if let logo = UIImage(named: "logo") {
                Image(uiImage: logo)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(zoom)
            } else {
                // Respaldo si todavía no agregaste el logo
                ZStack {
                    Circle().fill(WimbledonTheme.white)
                    Circle().strokeBorder(WimbledonTheme.purple, lineWidth: size * 0.04)
                    Image(systemName: "tennis.racket")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(WimbledonTheme.green)
                        .padding(size * 0.26)
                }
            }
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        .accessibilityLabel("Logo de Wimbledon")
    }
}

#Preview {
    WimbledonLogoView(size: 200)
        .padding()
        .background(WimbledonTheme.green)
}
