# Ledgerly — Seguimiento de Gastos Personales para iOS

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat-square&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5-0A84FF?style=flat-square&logo=apple)
![CoreData](https://img.shields.io/badge/CoreData-Almacenamiento_Local-6C757D?style=flat-square)
![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=flat-square&logo=firebase)
![Lottie](https://img.shields.io/badge/Lottie-4-00C4CC?style=flat-square)
Aplicación iOS nativa para el registro de gastos personales, construida con SwiftUI y arquitectura MVVM. Los gastos se almacenan localmente con Core Data, se sincronizan con un backend remoto mediante async/await, y la interfaz incluye localización en francés e inglés desde el primer momento.

---

## Problema que resuelve

La mayoría de aplicaciones de control de gastos son demasiado complejas (suites de presupuesto completas) o demasiado simples (notas planas). Ledgerly ocupa el punto intermedio: una herramienta enfocada en registrar gastos diarios, categorizarlos, visualizar patrones de gasto y recibir recordatorios diarios — todo sin cuenta de usuario ni dependencia de la nube.

Ledgerly lo resuelve proporcionando:
- Almacenamiento y gestión de usuarios mediante Firebase
- Almacenamiento local offline-first con Core Data — funciona sin conexión
- Filtrado por categoría y búsqueda en tiempo real con bindings reactivos de Combine
- Visualización de gastos por categoría con gráfico de barras usando Swift Charts
- Recordatorios push diarios con `UNUserNotificationCenter`
- Localización en francés e inglés usando el formato `.xcstrings` de Xcode 15

---

## Capturas de pantalla

### Inicio de sesión
Pantalla donde el usuario puede iniciar sesión, en caso de no tener puede clicar en el enlace inferior para registrarse.

<img src="assets/Main.png" width="300">

### Registro
Pantalla de registro de usuario.

<img src="assets/Main.png" width="300">

### Lista de gastos
Pantalla principal con barra de búsqueda, chips de filtro por categoría y lista completa de gastos.

<img src="assets/Main.png" width="300">

### Añadir gasto
Formulario en sheet para añadir un nuevo gasto con título, importe y selector de categoría. Lanza una animación Lottie de éxito al guardar.

<img src="assets/AddExpense.png" width="300">

### Gráfico de gastos
Gráfico de barras desglosando el gasto por categoría, renderizado con Swift Charts.

<img src="assets/Chart.png" width="300">

### Detalle de gasto
Vista completa de un gasto seleccionado: título, importe, categoría y fecha.

<img src="assets/Detail.png" width="300">

### Filtro
Puedes filtrar los gastos clickando en el menú de las categorías.

<img src="assets/Filter.png" width="300">

### Búsqueda
Puedes buscar un gasto por nombre.

<img src="assets/Search.png" width="300">

---

## Funcionalidades

### Lista de gastos
- Lista completa de todos los gastos locales con scroll
- Búsqueda en tiempo real sobre el título del gasto mediante pipeline de Combine
- Chips de filtro horizontal por categoría: Food / Transport / Bills / Other
- Eliminar con swipe con borrado inmediato en Core Data
- Botón de sincronización para traer gastos remotos al almacenamiento local

### Añadir gasto
- Modal en sheet con campo de título, campo de importe decimal y selector de categoría
- Botón de guardar desactivado hasta que título e importe estén rellenos
- Animación Lottie `.playOnce` al guardar; el sheet se cierra automáticamente tras 1 segundo

### Gráfico
- Gráfico de barras de todos los gastos agrupados por categoría
- Construido con Swift Charts — sin librería de gráficos de terceros

### Notificaciones
- Solicita autorización de `UNUserNotificationCenter` en el primer arranque
- Programa un recordatorio diario repetitivo a las 20:00
- Lanza también un recordatorio puntual 5 segundos después del arranque (para demostración)
- El contenido de las notificaciones usa claves localizadas de `.xcstrings`

---

## Stack tecnológico

| Capa | Tecnología | Motivo |
|------|-----------|--------|
| Lenguaje | Swift 5.9 | iOS nativo con soporte completo de Concurrency |
| Framework UI | SwiftUI | UI declarativa con aspecto nativo iOS |
| Arquitectura | MVVM | Separación limpia entre vista, estado y capa de datos |
| Almacenamiento local | Core Data | Persistencia offline-first de gastos |
| Autenticación | FireBase | Autenticación mediante acceso a firebase, permitiendo iniciar sesión, registrar y eliminar cuenta |
| Bindings reactivos | Combine | Búsqueda + filtro en tiempo real sin recargas manuales |
| Gráficos | Swift Charts | Gráfico de barras nativo sin dependencias |
| Animaciones | Lottie (iOS) | Animación de éxito al guardar un gasto |
| Notificaciones | UNUserNotificationCenter | Recordatorios diarios y alertas al arrancar |
| Red | URLSession + async/await | Fetch asíncrono tipado sin librería HTTP de terceros |
| Localización | `.xcstrings` (Xcode 15) | Catálogos de strings en francés e inglés con verificación en compilación |

---

## Estructura del proyecto

```
Ledgerly/
├── LedgerlyApp.swift                    #Punto de entrada — solicitud de permiso de notificaciones al arrancar
│
├── data/
│   ├── network/
│   │   └── NetworkService.swift         #NetworkServiceProtocol + fetch y POST async/await con URLSession
│   ├── persistence/
│   │   ├── CoreDataStack.swift          #Singleton NSPersistentContainer + acceso al viewContext
│   │   └── LedgerlyModel.xcdatamodeld   #Modelo Core Data — esquema de ExpenseEntity
│   └── repositories/
│       └── ExpenseRepository.swift      #Implementación de ExpenseRepositoryProtocol — CRUD + sincronización
│
├── domain/
│   ├── models/
│   │   └── Expense.swift                #Tipo de valor Expense — Identifiable + Codable
│   └── repositories/
│       └── ExpenseRepositoryProtocol.swift  #Protocolo que define la interfaz del repositorio
│
├── presentation/
│   ├── viewmodels/
│   │   ├── ExpenseListViewModel.swift   #@MainActor ObservableObject — pipeline Combine + acciones CRUD
│   │   ├── AuthViewModel.swift   		 #Mediador entre el servicio y la vista para poder acceder a firebase
│   │   └── LottieView.swift             #Wrapper UIViewRepresentable para Lottie
│   └── views/
│       ├── LedgerlyTabView.swift        #TabView raíz — pestaña de lista + pestaña de gráfico
│       ├── AddExpenseView.swift         #Formulario en sheet con animación Lottie de éxito
│       ├── ExpenseDetailView.swift      #Pantalla de detalle de un gasto seleccionado
│       ├── ExpensesChartView.swift      #Gráfico de barras por categoría con Swift Charts
│       └── CategoriesGridView.swift     #Chips de filtro por categoría con scroll horizontal
│
│
└── services/
    ├── AuthService.swift  		     #AuthService, conexión a firebase para poder acceder a la cuenta del usaurio
    ├── NotificationService.swift    #Programación de notificaciones diarias y al arrancar
    └── NotificationDelegate.swift   #Delegado para que las notificaciones se muestren y con sonido
```

---

## Arquitectura

Ledgerly sigue una estructura MVVM estricta con patrón repositorio que separa la persistencia de la capa de vista.

```
Vista (SwiftUI)
  └── ExpenseListViewModel (@MainActor, ObservableObject)
        └── ExpenseRepositoryProtocol
              └── ExpenseRepository (CoreData + Network)
                	   ├── CoreDataStack (NSPersistentContainer)
                	   └── NetworkService (URLSession async/await)

```

El `ExpenseListViewModel` mantiene dos arrays `@Published`: `expenses` (datos en bruto) y `filteredExpenses` (derivado). Un publisher `CombineLatest` sobre `searchText` y `selectedCategory` recalcula `filteredExpenses` reactivamente en cada pulsación o cambio de filtro — sin llamadas manuales de recarga desde la vista.

---

## Decisiones de arquitectura

### Offline-first con Core Data
Todos los gastos se escriben y leen desde Core Data en primer lugar. El backend remoto (`jsonplaceholder.typicode.com`) solo se llama explícitamente mediante el botón de sincronización. `syncWithBackend()` descarga los gastos remotos e inserta únicamente aquellos cuyo `UUID` no existe ya en local — sin duplicados ni sobreescrituras.

### Combine para filtrado reactivo
En lugar de filtrar dentro del cuerpo del `List` o usando `.onChange`, el pipeline de filtrado vive íntegramente en el ViewModel con `Publishers.CombineLatest`. Esto mantiene la vista puramente declarativa y hace la lógica de filtrado testeable de forma independiente.

### Repositorio basado en protocolo
`ExpenseRepositoryProtocol` se inyecta en el ViewModel en el `init`. Esto hace toda la capa de datos intercambiable — un `MockExpenseRepository` puede inyectarse en tests o Previews de Xcode sin tocar ningún código de vista.

### @MainActor en toda la capa de datos
Tanto `ExpenseListViewModel` como `ExpenseRepository` están anotados con `@MainActor`. Esto evita condiciones de carrera sobre el `viewContext` de Core Data (que solo puede usarse en el hilo principal) y elimina el boilerplate de `DispatchQueue.main.async` al actualizar propiedades `@Published` desde funciones asíncronas.

### Animación Lottie con auto-dismiss
`AddExpenseView` muestra una animación Lottie `.playOnce` en un sheet al guardar. Un `DispatchQueue.main.asyncAfter` se dispara tras 1 segundo para llamar a `dismiss()`, cerrando el sheet automáticamente sin acción del usuario — imitando los patrones de confirmación nativos de iOS.

---

## Localización

Todas las cadenas visibles al usuario usan el formato de catálogo `.xcstrings` de Xcode 15. Las claves se pasan como `String(localized: "clave")` o directamente como `LocalizedStringKey` en las vistas SwiftUI.

| Clave                    | Inglés                                                           | Español                                                | Francés                                                             |
| ------------------------ | ---------------------------------------------------------------- | ------------------------------------------------------ | ------------------------------------------------------------------- |
| `€`                      | $                                                                | €                                                      | €                                                                   |
| `Ledgerly`               | Ledgerly                                                         | Ledgerly                                               | Ledgerly                                                            |
| `cancel_button`          | Cancel                                                           | Cancelar                                               | Annuler                                                             |
| `close_button`           | Close                                                            | Cerrar                                                 | Fermer                                                              |
| `delete_account_confirm` | Delete                                                           | Eliminar                                               | Supprimer                                                           |
| `delete_account_message` | This will permanently delete your account and all your expenses. | Eliminará permanentemente tu cuenta y todos tus gastos | Cela supprimera définitivement votre compte et toutes vos dépenses. |
| `delete_account_title`   | Delete Account                                                   | Eliminar cuenta                                        | Supprimer le compte                                                 |
| `expense_date`           | Date                                                             | Fecha                                                  | Date                                                                |
| `field_amount`           | Amount                                                           | Cantidad                                               | Montant                                                             |
| `field_confirm_password` | Confirm Password                                                 | Confirmar contraseña                                   | Confirmer le mot de passe                                           |
| `field_email`            | Email                                                            | Correo electrónico                                     | E-mail                                                              |
| `field_password`         | Password                                                         | Contraseña                                             | Mot de passe                                                        |
| `field_title`            | Title                                                            | Título                                                 | Titre                                                               |
| `login_button`           | Sign In                                                          | Iniciar sesión                                         | Se connecter                                                        |
| `login_subtitle`         | Sign in to your account                                          | Inicia sesión en tu cuenta                             | Connectez-vous à votre compte                                       |
| `new_expense_title`      | New Expense                                                      | Nuevo gasto                                            | Nouvelle dépense                                                    |
| `no_account_label`       | Don't have an account?                                           | ¿No tienes cuenta?                                     | Vous n'avez pas de compte ?                                         |
| `notification_body`      | Record your daily expenses...                                    | Registra tus gastos diarios...                         | Enregistre tes dépenses du jour...                                  |
| `notification_title`     | Don't forget your expenses                                       | No olvides tus gastos                                  | N'oublie pas tes dépenses                                           |
| `picker_category`        | Select category                                                  | Selecciona categoría                                   | Choisir une catégorie                                               |
| `save_button`            | Save                                                             | Guardar                                                | Enregistrer                                                         |
| `search_placeholder`     | Search expense...                                                | Buscar gasto…                                          | Rechercher une dépense...                                           |
| `section_amount`         | Amount                                                           | Cantidad                                               | Montant                                                             |
| `section_category`       | Category                                                         | Categoría                                              | Catégorie                                                           |
| `section_details`        | Details                                                          | Detalles                                               | Détails                                                             |
| `signup_button`          | Create Account                                                   | Crear cuenta                                           | Créer un compte                                                     |
| `signup_link`            | Sign Up                                                          | Regístrate                                             | S'inscrire                                                          |
| `signup_subtitle`        | Track your expenses                                              | Registra tus gastos                                    | Suivez vos dépenses                                                 |
| `signup_title`           | Create Account                                                   | Crear cuenta                                           | Créer un compte                                                     |
| `sync_button`            | Sync                                                             | Sync                                                   | Sync                                                                |
| `tab_chart`              | Chart                                                            | Gráfico                                                | Graphique                                                           |
| `tab_expenses`           | Expenses                                                         | Gastos                                                 | Dépenses                                                            |
| `total_amount`           | Total amount                                                     | Importe total                                          | Montant total                                                       |

---

## Ejecución en local

```bash
#Clonar el repositorio
git clone https://github.com/AdrianMalmierca/LedgerlyIOS.git
cd Ledgerly

# Abrir en Xcode
open Ledgerly.xcodeproj
```

Selecciona un simulador o dispositivo iOS conectado y pulsa **Run** (⌘R). No se requiere configuración adicional — el esquema Core Data está incluido en el bundle y la capa de red apunta a una API pública sin autenticación.

### Requisitos

- Xcode 15+
- Deployment target iOS 17+
- Swift Package Manager (las dependencias se resuelven automáticamente en el primer build)

---

## Qué aprendí construyendo esto

### Core Data con async/await
Combinar el `viewContext` de Core Data (ligado al hilo principal) con la concurrencia estructurada de Swift requirió entender `@MainActor` como una garantía en tiempo de compilación, no como una anotación en tiempo de ejecución. Anotar el repositorio con `@MainActor` hizo el modelo de concurrencia explícito y eliminó una clase entera de posibles bugs de threading.

### Pipelines de Combine en MVVM
`CombineLatest` fue el operador correcto para combinar dos streams de filtro independientes, pero requirió entender el ciclo de vida de la suscripción — almacenar el `AnyCancellable` en un `Set` es obligatorio, no opcional. Dejarlo escapar del scope cancela la suscripción silenciosamente sin ningún error, que fue el primer bug que tuve que depurar.

### Lottie con UIViewRepresentable
Integrar una librería de animación basada en UIKit en SwiftUI mediante `UIViewRepresentable` expuso cómo el sistema de layout de SwiftUI difiere del modelo `frame`-based de UIKit. Establecer `translatesAutoresizingMaskIntoConstraints = false` y anclar la vista de animación a los anchors del contenedor fue el patrón correcto — no establecer un frame explícito sobre la vista Lottie.

### .xcstrings frente a .strings
El formato `.xcstrings` de Xcode 15 es una mejora significativa respecto a los ficheros `.strings` legacy — las claves y traducciones viven en un único fichero JSON, las traducciones faltantes se resaltan en tiempo de compilación y las reglas de pluralización son ciudadanos de primera clase. La migración desde `.strings` es en un solo sentido y merece hacerse desde el principio.

### Flujo de permisos de UNUserNotificationCenter
La solicitud de permiso de notificaciones debe producirse en el momento adecuado del ciclo de vida — demasiado pronto (antes de que cargue la primera pantalla) y los usuarios la descartan sin contexto; demasiado tarde y nunca se dispara. Colocar la solicitud en el `onAppear` de la vista raíz, con un contexto explicativo breve visible en pantalla, produjo la mayor tasa de concesión en las pruebas.

---

## Mejoras futuras

### Corto plazo
- **Editar gasto** — edición inline de gastos existentes al pulsar sobre ellos
- **Límites de presupuesto** — establecer un tope mensual por categoría con indicador de advertencia
- **Exportación** — compartir gastos como CSV

### Medio plazo
- **Widgets** — widget de pantalla de inicio con WidgetKit mostrando el gasto total del día

### Largo plazo
- **App para Apple Watch** — añadir gasto rápido desde la muñeca
- **Gastos recurrentes** — marcar un gasto como mensual e insertarlo automáticamente

---

## Licencia

MIT — libre de usar, modificar y desplegar.

---

## Autor

**Adrián Martín Malmierca**  
Ingeniero Informático y Estudiante de Máster en Aplicaciones Móviles  
[GitHub](https://github.com/AdrianMalmierca) · [LinkedIn](https://www.linkedin.com/in/adri%C3%A1n-mart%C3%ADn-malmierca-4aa6b0293/)
