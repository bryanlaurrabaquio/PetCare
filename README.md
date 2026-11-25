# Psh Psh — SwiftUI + MVVM + SwiftData

App para el cuidado de mascotas: salud, servicios, seguros y finanzas. (Internamente el proyecto se llama `PetCare`.)

Requisitos: Xcode 16 o superior, iOS 17 como versión mínima.

## Cómo abrirlo
1. Clona el repo: `git clone https://github.com/bryanlaurrabaquio/PetCare.git`
2. Abre **`PetCare.xcodeproj`** (doble clic, o en Xcode: File → Open… → `PetCare.xcodeproj`). No abras la carpeta sola.
3. Arriba elige un simulador de iPhone y presiona ▶️ (⌘R).
4. Para correrlo en tu iPhone: proyecto PetCare → target PetCare → Signing & Capabilities → elige tu Team.

El proyecto usa carpetas sincronizadas (Xcode 16): cualquier archivo que agregues dentro de `PetCare/` entra solo al proyecto.
Las fotos de demo (`luna`, `max`, `michi`) se buscan en `PetCare/Assets.xcassets`; si no están, se muestra el ícono de la especie.

## Flujo
Pantalla de carga con animales (cada vez que se abre; botón "Saltar") → bienvenida (solo la primera vez) → registro / inicio de sesión → alta de mascotas (paso obligatorio la primera vez) → app con 5 pestañas.

## Estructura
- **Models/**: modelos de SwiftData (`UserAccount`, `PetRecord`, `PetEvent`, `Vaccine`, `Medication`, `Consultation`, `Expense`) y "drafts" para formularios.
- **Services/**: `AuthService` (cuentas locales con contraseña con hash), `PetCareStore` (todas las lecturas y escrituras, filtradas por usuario) y `SampleData` (datos de demo).
- **ViewModels/**: un ViewModel por pantalla.
- **Views/**: Auth, Onboarding, Home, Services, Health, Finance, Pets y componentes compartidos.

## Seguros para mascotas
En **Servicios → Seguro para tu mascota**:
- 4 aseguradoras de ejemplo (nombres ficticios) con planes, coberturas, suma asegurada, deducible, coaseguro y periodo de espera.
- Contratar una póliza para una mascota (pago mensual o anual con 10 % de descuento; opcionalmente se registra el pago en Finanzas).
- Consultar cada póliza: número, vigencia y días restantes, coberturas incluidas, pago y próximo cobro; compartirla o cancelarla.
- Catálogo en `Models/Insurance.swift`; pantallas en `Views/Services/InsuranceViews.swift`.

## Pantalla de carga
`Views/Launch/SplashView.swift`. Dura `SplashView.duration` segundos (60 por defecto) y cambia de animal cada `animalInterval`.

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
