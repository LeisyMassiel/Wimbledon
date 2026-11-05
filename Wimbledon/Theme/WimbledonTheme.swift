import SwiftUI

enum WimbledonTheme {
    // olores oficiales
    static let green  = Color(red: 0/255,  green: 102/255, blue: 51/255)
    static let purple = Color(red: 84/255, green: 0/255,   blue: 139/255)
    static let white  = Color(red: 1, green: 1, blue: 1)

    // Versiones UIKit (para la barra de navegación y los segmentos)
    static let uiGreen  = UIColor(red: 0/255,  green: 102/255, blue: 51/255,  alpha: 1)
    static let uiPurple = UIColor(red: 84/255, green: 0/255,   blue: 139/255, alpha: 1)

    // Derivados (solo transparencias de los colores oficiales)
    static let fieldBackground = green.opacity(0.06)
    static let fieldBorder     = green.opacity(0.30)
    static let secondaryText   = Color.black.opacity(0.6)
    static let errorRed        = Color(red: 0.75, green: 0.11, blue: 0.16)

    /// Degradado verde → púrpura (predomina el verde)
    static let brandGradient = LinearGradient(
        colors: [green, green, purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum WimbledonFont {
    static func regular(_ size: CGFloat)  -> Font { .custom("Montserrat-Regular", size: size) }
    static func medium(_ size: CGFloat)   -> Font { .custom("Montserrat-Medium", size: size) }
    static func semibold(_ size: CGFloat) -> Font { .custom("Montserrat-SemiBold", size: size) }
    static func bold(_ size: CGFloat)     -> Font { .custom("Montserrat-Bold", size: size) }
}
