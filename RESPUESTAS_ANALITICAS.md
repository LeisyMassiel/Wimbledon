# Respuestas analíticas — Caso 4: Aplicación para el torneo de Wimbledon

## 1. Splash — ¿Por qué usar `@State` y no `@StateObject` para controlar la navegación del Splash?

La navegación del Splash depende de un único valor: `@State private var isActive = false` en `SplashView`. Es un `Bool` (tipo valor), es privado y solo lo lee y escribe esa vista. Para ese caso existe `@State`: SwiftUI guarda el valor fuera del struct de la vista, lo mantiene entre redibujados y vuelve a dibujar el `body` cuando cambia.

`@StateObject` sirve para crear y conservar una **instancia de una clase** que conforma `ObservableObject`, con varias propiedades `@Published` y lógica propia. Usarlo aquí implicaría:
- Crear una clase extra (por ejemplo `SplashViewModel`) solo para envolver un `Bool`, sin lógica de negocio que lo justifique.
- Asignar memoria en el heap, contar referencias y montar Combine (`objectWillChange`) para algo que `@State` resuelve con un valor simple.
- Más acoplamiento y código sin ningún beneficio, porque el estado no se comparte con otras vistas ni sobrevive al Splash.

**Decisión:** `@State` es la herramienta correcta para estado de UI local, simple y de tipo valor. `@StateObject` queda para modelos de referencia con lógica, como `LoginViewModel` o `HomeViewModel`.

## 2. Login — ¿Qué diferencia hay entre bindear `viewModel.email` con `$` y pasar una copia del valor?

- `TextField("Correo", text: $viewModel.email)` pasa un **`Binding<String>`**: una referencia de lectura **y escritura** a la propiedad `@Published var email` del `LoginViewModel`. Cada tecla actualiza el ViewModel al instante; eso dispara `objectWillChange`, SwiftUI vuelve a evaluar la vista y se recalculan `isFormEmpty` (que activa o desactiva el botón con `.disabled`) y el `didSet` que borra el `errorMessage`. Hay una sola fuente de verdad.
- Pasar `viewModel.email` sin `$` entrega una **copia del `String`** (los `String` son tipos valor). La vista recibe un valor de solo lectura con la foto del momento: lo que escribe el usuario no vuelve al ViewModel. Por eso `TextField` ni siquiera compila con un `String`: exige `Binding<String>`. Aunque se armara a mano un `Binding(get:set:)`, sería duplicar lo que `$` ya hace bien.

**Decisión:** usar `$viewModel.email`. La validación vive en el ViewModel y necesita leer siempre el valor actual que escribe el usuario. Con una copia, el ViewModel validaría un texto desactualizado.

## 3. Registro — ¿Por qué conviene usar `@EnvironmentObject` para el usuario autenticado en lugar de pasarlo por cada vista?

`AuthViewModel` (lista de usuarios + `currentUser`) se crea una sola vez con `@StateObject` en `WimbledonApp` y se inyecta con `.environmentObject(authViewModel)`. Así:
1. **No hay "prop drilling":** Splash, AppFlow, Login y Navigation no necesitan recibir el usuario por `init` solo para pasárselo a sus hijos. Lo leen las vistas que lo usan: `LoginView`, `RegisterView` y `HomeView`.
2. **Única fuente de verdad compartida:** cuando `RegisterViewModel` llama a `auth.register(user)` y `auth.signIn(user)`, `AppFlowView` (que observa `currentUser`) cambia sola de Login a Home. El logout funciona igual al revés: `currentUser = nil` y vuelve el Login.
3. **Reactividad automática:** cualquier vista suscrita se actualiza cuando cambia un `@Published`, sin callbacks ni delegados.
4. **Menor acoplamiento y más fácil de mantener:** agregar una pantalla nueva que necesite el usuario no obliga a cambiar las firmas de las vistas intermedias.

Precaución: si una vista declara `@EnvironmentObject` y nadie lo inyectó, la app falla en tiempo de ejecución. Por eso los `#Preview` también lo inyectan.

## 4. Home — Si el filtrado se calcula en la Vista con `.filter` dentro del `body`, ¿qué problema de rendimiento puede surgir y cómo se resuelve con el ViewModel?

El `body` se vuelve a evaluar muchas veces: por cada tecla en la búsqueda, cada cambio de cualquier `@Published` del ViewModel, cada animación o rotación, etc. Si el `.filter` está dentro del `body`:
- Se recorre **todo** el array (O(n)) en **cada** redibujado, aunque no hayan cambiado ni los datos ni el texto.
- Con listas grandes o comparaciones costosas (`localizedStandardContains`, que ignora mayúsculas y tildes) el trabajo se repite y aparecen saltos al escribir.
- Se genera un array nuevo cada vez, y `List` tiene que volver a comparar identidades para encontrar diferencias.
- La lógica de negocio queda mezclada con la UI y no se puede probar por separado.

**Solución aplicada en `HomeViewModel`:** el ViewModel expone `@Published private(set) var filteredItems` y lo calcula con Combine **solo cuando cambian sus entradas**:
```swift
Publishers.CombineLatest3($items,
                          $searchText.debounce(for: .milliseconds(200), scheduler: RunLoop.main).removeDuplicates(),
                          $selectedFilter)
    .map { HomeViewModel.filter($0, text: $1, filter: $2) }
    .assign(to: &$filteredItems)
```
- `debounce` espera a que el usuario pare de escribir (200 ms) y `removeDuplicates` evita filtrar dos veces el mismo texto.
- El `body` solo **lee** `viewModel.filteredItems`, ya calculado, sin trabajo extra.
- El filtrado es una función pura y se puede probar con tests unitarios.

## 5. Detalle — ¿Por qué es mejor que el detalle reciba un `ItemModel` por valor (struct) y no una referencia (`@ObservedObject`)? ¿Cuándo podría cambiar esa decisión?

`DetailView` declara `let item: ItemModel`, y `ItemModel` es un `struct` `Identifiable` y `Hashable`.

**Por qué por valor:**
- **Solo lectura:** el detalle solo muestra los datos del campeón; no los edita. Un `let` con un struct garantiza que nada lo modifique por accidente.
- **Inmutabilidad y seguridad:** el struct se copia, así que no hay efectos secundarios compartidos ni riesgos de hilos. Lo que haga el detalle no afecta al listado.
- **Rendimiento y simplicidad:** no hay heap, ni conteo de referencias, ni suscripción Combine. La vista no se redibuja por cambios ajenos.
- **Encaja con `navigationDestination(for: ItemModel.self)`,** que necesita un valor `Hashable`.
- `@ObservedObject` obligaría a convertir el modelo en una `class ObservableObject` y a manejar su ciclo de vida (quién lo crea, quién lo retiene), sin ningún beneficio para una pantalla de solo lectura.

**Cuándo cambiaría:**
- Si el detalle tuviera que **editar** el elemento y que el cambio se viera en el listado (por ejemplo, marcar un campeón como favorito): se usaría `@Binding` al elemento o un ViewModel compartido.
- Si los datos cambiaran **en vivo** mientras la pantalla está abierta (por ejemplo, el marcador de un partido en curso durante el torneo): el detalle necesitaría observar un objeto de referencia (`@ObservedObject` o `@StateObject` de un `MatchViewModel`) para actualizarse solo.
- Si el modelo fuera muy pesado y copiarlo costara mucho, o si hubiera que compartir la misma instancia entre varias pantallas.
