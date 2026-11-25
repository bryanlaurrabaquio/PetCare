# PetCare — SwiftUI + MVVM + SwiftData

Requisitos: Xcode 16 o superior, iOS 17 como versión mínima.

## Cómo agregarlo al proyecto
1. En Xcode, borra del proyecto las carpetas de la versión anterior (`App`, `Core`, `Models`, `Services`, `ViewModels`, `Views`) → "Move to Trash".
2. Arrastra las carpetas de este zip al proyecto ("Copy items if needed").
3. Borra la app del simulador (mantén presionado el ícono → Eliminar app) para empezar con la base de datos limpia.
4. ⌘⇧K y luego ⌘R.

## Flujo
Registro / inicio de sesión → alta de mascotas (paso obligatorio la primera vez) → app con 5 pestañas.

## Estructura
- **Models/**: modelos de SwiftData (`UserAccount`, `PetRecord`, `PetEvent`, `Vaccine`, `Medication`, `Consultation`, `Expense`) y "drafts" para formularios.
- **Services/**: `AuthService` (cuentas locales con contraseña con hash), `PetCareStore` (todas las lecturas y escrituras, filtradas por usuario) y `SampleData` (datos de demo).
- **ViewModels/**: un ViewModel por pantalla.
- **Views/**: Auth, Onboarding, Home, Services, Health, Finance, Pets y componentes compartidos.

## Diseño
- Paleta morada con fondo lavanda claro. Todos los colores, degradados y sombras viven en `Core/Theme.swift`.
- Decoraciones (huellitas en los encabezados, logo de huella con corazón, fondo, ilustraciones) en `Views/Shared/Decorations.swift`.
- Botón principal: `.buttonStyle(.primaryFilled)`; tarjetas: `.cardBackground()`; encabezados: `ScreenHeader(..., decoration: .paws | .heartPaw | .hidden)`.
- Carrusel de bienvenida (`Views/Onboarding/IntroView.swift`): se muestra una sola vez antes del registro. Para verlo otra vez, borra la app del simulador.
- La app usa siempre modo claro (`.preferredColorScheme(.light)` en `PetCareApp`).

## Privacidad de datos
Cada mascota guarda el `ownerID` de su dueño y `PetCareStore` solo consulta las mascotas de ese usuario; los eventos, vacunas y gastos cuelgan de la mascota. Los datos viven en el dispositivo.
Para cuentas en la nube (varios dispositivos), implementa `AuthService` con Firebase Auth y sincroniza con Firestore.

## Si cambias un modelo de SwiftData
Si la app truena al abrir después de cambiar un `@Model`, borra la app del simulador y vuelve a correrla.
