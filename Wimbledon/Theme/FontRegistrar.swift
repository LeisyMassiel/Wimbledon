//
//  FontRegistrar.swift
//  Registra las fuentes Montserrat empaquetadas en la app en tiempo de ejecución,
//  así no hace falta tocar el Info.plist (clave UIAppFonts).
//

import CoreText
import Foundation

enum FontRegistrar {
    private static let fontFiles = [
        "Montserrat-Regular",
        "Montserrat-Medium",
        "Montserrat-SemiBold",
        "Montserrat-Bold"
    ]

    static func registerFonts() {
        for file in fontFiles {
            guard let url = Bundle.main.url(forResource: file, withExtension: "ttf") else {
                print("⚠️ No se encontró la fuente \(file).ttf en el bundle")
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
