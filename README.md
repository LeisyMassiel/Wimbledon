# Wimbledon — The Championships (Caso 4)

App iOS en **SwiftUI + MVVM** para la Evaluación 03 de Desarrollo de Aplicaciones en iOS (Tecsup).

## Cómo abrirla
1. Abrir `Wimbledon.xcodeproj` con **Xcode 16 o superior** (deployment target iOS 17).
2. **Agregar el logo oficial:** en el navegador del proyecto, abrir `Assets.xcassets › WimbledonLogo` y arrastrar el PNG del logo oficial de Wimbledon (raquetas cruzadas con la pelota) al recuadro **1x/2x/3x** (con uno basta). Mientras no esté, la app muestra el símbolo `tennis.racket` como respaldo.
3. Elegir un simulador de iPhone y ejecutar con ⌘R.
4. Usuario de prueba: `demo@wimbledon.com` / `Wimbledon#2026` (o crear uno nuevo en Registro).

> Si tienes Xcode 15: crea un proyecto nuevo (iOS › App, SwiftUI, nombre *Wimbledon*), borra `ContentView.swift` y el `WimbledonApp.swift` que se genera, y arrastra la carpeta `Wimbledon/` completa (marcando *Copy items if needed* y el target).

## Identidad de marca usada (nada al azar)
| Elemento | Valor | Fuente |
|---|---|---|
| Verde | Pantone 349 C · `#046A38` | Marca registrada del AELTC (UK00003095405) |
| Púrpura | Pantone 268 C · `#582C83` | Marca registrada del AELTC (UK00003095405) |
| Blanco | `#FFFFFF` | Regla "predominantly white" del torneo |
| Tipografía | Montserrat (OFL), alternativa libre de **Gotham**, la fuente del wordmark actual | Rediseño del logo de 2011 |
| Recurso gráfico | Doble franja verde/púrpura (`WimbledonStripe`) | Identidad web y de impresos del torneo |

## Estructura
```
Wimbledon/
├─ App/          WimbledonApp (inyecta AuthViewModel), AppFlowView
├─ Theme/        Colores, fuentes, registro de fuentes, apariencia UIKit
├─ Models/       ItemModel (struct Identifiable), datos reales 2022–2026, User
├─ ViewModels/   AuthViewModel (EnvironmentObject), Login, Register, Home
├─ Utils/        Validator (email y contraseña)
├─ Views/        Splash, Login, Register, Home, Detail + Components
└─ Resources/    Fuentes Montserrat
```

## Requisitos por pantalla
- **Splash:** logo con `scaleEffect` + `opacity`, nombre con `.font(.custom)`, `Task.sleep(2 s)`, navegación con `@State`.
- **Login:** `SecureField`, `.disabled` si hay campos vacíos, validación en `LoginViewModel` (email, ≥ 6 caracteres, 1 mayúscula, 1 carácter especial que no sea `. , ;` ni tilde), error con `@Published`, datos válidos guardados en `validatedEmail`/`validatedPassword`, enlace a Registro.
- **Registro:** 4 campos, ningún campo vacío, email único contra la lista en memoria, contraseñas iguales, guardado en `@EnvironmentObject`, banner "¡Cuenta creada!" 1,5 s antes de ir al Home.
- **Home:** `@Published var items: [ItemModel]` con 10 campeones reales, `List` con SF Symbol + nombre + subtítulo, `.searchable` con filtrado reactivo en el ViewModel (Combine + debounce), filtro Caballeros/Damas, logout.
- **Detalle:** `navigationDestination(for: ItemModel.self)`, hero grande arriba, nombre como título, 6 atributos + dato histórico, `ScrollView`.

Las respuestas analíticas están en `RESPUESTAS_ANALITICAS.md`.
