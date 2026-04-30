# Ledgerly — Personal Expense Tracker for iOS

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=flat-square&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5-0A84FF?style=flat-square&logo=apple)
![CoreData](https://img.shields.io/badge/CoreData-Local_Storage-6C757D?style=flat-square)
![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?style=flat-square&logo=firebase)
![Lottie](https://img.shields.io/badge/Lottie-4-00C4CC?style=flat-square)

Native iOS application for tracking personal expenses, built with SwiftUI and MVVM architecture. Expenses are stored locally with Core Data, synced with a remote backend via async/await, and the interface includes French and English localization from day one.

---

## Problem Statement

Most expense-tracking apps are either too complex (full budget suites) or too simple (flat notes). Ledgerly occupies the middle ground: a focused tool for logging daily expenses, categorizing them, visualizing spending patterns, and receiving daily reminders — all without requiring a user account or cloud dependency.

Ledgerly solves this by providing:
- User storage and management via Firebase
- Offline-first local storage with Core Data — works without a connection
- Category filtering and real-time search with reactive Combine bindings
- Per-category spending visualization with a bar chart using Swift Charts
- Daily push reminders with `UNUserNotificationCenter`
- French and English localization using Xcode 15's `.xcstrings` format

---

## Screenshots

### Login
Screen where the user can sign in; if they don't have an account, they can tap the link at the bottom to register.

<img src="assets/Main.png" width="300">

### Register
User registration screen.

<img src="assets/Main.png" width="300">

### Expense List
Main screen with a search bar, category filter chips, and the full expense list.

<img src="assets/Main.png" width="300">

### Add Expense
Sheet form for adding a new expense with title, amount, and category picker. Fires a Lottie success animation on save.

<img src="assets/AddExpense.png" width="300">

### Expense Chart
Bar chart breaking down spending by category, rendered with Swift Charts.

<img src="assets/Chart.png" width="300">

### Expense Detail
Full view of a selected expense: title, amount, category, and date.

<img src="assets/Detail.png" width="300">

### Filter
Filter expenses by tapping on the category menu.

<img src="assets/Filter.png" width="300">

### Search
Search for an expense by name.

<img src="assets/Search.png" width="300">

---

## Features

### Expense List
- Full scrollable list of all local expenses
- Real-time search on the expense title via a Combine pipeline
- Horizontal category filter chips: Food / Transport / Bills / Other
- Swipe-to-delete with immediate Core Data removal
- Sync button to pull remote expenses into local storage

### Add Expense
- Sheet modal with a title field, decimal amount field, and category picker
- Save button disabled until both title and amount are filled in
- Lottie `.playOnce` animation on save; the sheet auto-dismisses after 1 second

### Chart
- Bar chart of all expenses grouped by category
- Built with Swift Charts — no third-party charting library

### Notifications
- Requests `UNUserNotificationCenter` authorization on first launch
- Schedules a repeating daily reminder at 20:00
- Also fires a one-time reminder 5 seconds after launch (for demonstration)
- Notification content uses localized keys from `.xcstrings`

---

## Tech Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Language | Swift 5.9 | Native iOS with full Concurrency support |
| UI Framework | SwiftUI | Declarative UI with native iOS look and feel |
| Architecture | MVVM | Clean separation between view, state, and data layer |
| Local Storage | Core Data | Offline-first expense persistence |
| Authentication | Firebase | Firebase-backed auth: sign in, register, and delete account |
| Reactive Bindings | Combine | Real-time search + filter without manual reloads |
| Charts | Swift Charts | Native bar chart with no dependencies |
| Animations | Lottie (iOS) | Success animation when saving an expense |
| Notifications | UNUserNotificationCenter | Daily reminders and launch-time alerts |
| Networking | URLSession + async/await | Typed async fetch without a third-party HTTP library |
| Localization | `.xcstrings` (Xcode 15) | French and English string catalogs with compile-time verification |

---

## Project Structure

```
Ledgerly/
├── LedgerlyApp.swift                    #Entry point — notification permission request on launch
│
├── data/
│   ├── network/
│   │   └── NetworkService.swift         #NetworkServiceProtocol + async/await fetch and POST with URLSession
│   ├── persistence/
│   │   ├── CoreDataStack.swift          #NSPersistentContainer singleton + viewContext access
│   │   └── LedgerlyModel.xcdatamodeld  #Core Data model — ExpenseEntity schema
│   └── repositories/
│       └── ExpenseRepository.swift      #ExpenseRepositoryProtocol implementation — CRUD + sync
│
├── domain/
│   ├── models/
│   │   └── Expense.swift                #Expense value type — Identifiable + Codable
│   └── repositories/
│       └── ExpenseRepositoryProtocol.swift  # Protocol defining the repository interface
│
├── presentation/
│   ├── viewmodels/
│   │   ├── ExpenseListViewModel.swift   #@MainActor ObservableObject — Combine pipeline + CRUD actions
│   │   ├── AuthViewModel.swift          #Mediator between the auth service and the view for Firebase access
│   │   └── LottieView.swift             #UIViewRepresentable wrapper for Lottie
│   └── views/
│       ├── LedgerlyTabView.swift        #Root TabView — list tab + chart tab
│       ├── AddExpenseView.swift         #Sheet form with Lottie success animation
│       ├── ExpenseDetailView.swift      #Detail screen for a selected expense
│       ├── ExpensesChartView.swift      #Per-category bar chart with Swift Charts
│       └── CategoriesGridView.swift     #Horizontal-scroll category filter chips
│
└── services/
    ├── AuthService.swift                #Firebase connection for user account access
    ├── NotificationService.swift        #Daily and launch-time notification scheduling
    └── NotificationDelegate.swift       #Delegate for foreground notification display with sound
```

---

## Architecture

Ledgerly follows a strict MVVM structure with a repository pattern that separates persistence from the view layer.

```
View (SwiftUI)
  └── ExpenseListViewModel (@MainActor, ObservableObject)
        └── ExpenseRepositoryProtocol
              └── ExpenseRepository (CoreData + Network)
                       ├── CoreDataStack (NSPersistentContainer)
                       └── NetworkService (URLSession async/await)
```

`ExpenseListViewModel` maintains two `@Published` arrays: `expenses` (raw data) and `filteredExpenses` (derived). A `CombineLatest` publisher over `searchText` and `selectedCategory` reactively recalculates `filteredExpenses` on every keystroke or filter change — no manual reload calls from the view.

---

## Architecture Decisions

### Offline-first with Core Data
All expenses are written to and read from Core Data first. The remote backend (`jsonplaceholder.typicode.com`) is only called explicitly via the sync button. `syncWithBackend()` downloads remote expenses and inserts only those whose `UUID` does not already exist locally — no duplicates, no overwrites.

### Combine for Reactive Filtering
Rather than filtering inside the `List` body or using `.onChange`, the filtering pipeline lives entirely in the ViewModel using `Publishers.CombineLatest`. This keeps the view purely declarative and makes the filtering logic independently testable.

### Protocol-based Repository
`ExpenseRepositoryProtocol` is injected into the ViewModel at `init`. This makes the entire data layer swappable — a `MockExpenseRepository` can be injected in tests or Xcode Previews without touching any view code.

### @MainActor Across the Data Layer
Both `ExpenseListViewModel` and `ExpenseRepository` are annotated with `@MainActor`. This prevents race conditions on Core Data's `viewContext` (which can only be used on the main thread) and eliminates `DispatchQueue.main.async` boilerplate when updating `@Published` properties from async functions.

### Lottie Animation with Auto-dismiss
`AddExpenseView` presents a Lottie `.playOnce` animation in a sheet on save. A `DispatchQueue.main.asyncAfter` fires after 1 second to call `dismiss()`, closing the sheet automatically without user interaction — mimicking native iOS confirmation patterns.

---

## Localization

All user-visible strings use Xcode 15's `.xcstrings` catalog format. Keys are passed as `String(localized: "key")` or directly as `LocalizedStringKey` in SwiftUI views.

| Key | English | Spanish | French |
|-----|---------|---------|--------|
| `cancel_button` | Cancel | Cancelar | Annuler |
| `close_button` | Close | Cerrar | Fermer |
| `delete_account_confirm` | Delete | Eliminar | Supprimer |
| `delete_account_message` | This will permanently delete your account and all your expenses. | Eliminará permanentemente tu cuenta y todos tus gastos | Cela supprimera définitivement votre compte et toutes vos dépenses. |
| `delete_account_title` | Delete Account | Eliminar cuenta | Supprimer le compte |
| `expense_date` | Date | Fecha | Date |
| `field_amount` | Amount | Cantidad | Montant |
| `field_confirm_password` | Confirm Password | Confirmar contraseña | Confirmer le mot de passe |
| `field_email` | Email | Correo electrónico | E-mail |
| `field_password` | Password | Contraseña | Mot de passe |
| `field_title` | Title | Título | Titre |
| `login_button` | Sign In | Iniciar sesión | Se connecter |
| `login_subtitle` | Sign in to your account | Inicia sesión en tu cuenta | Connectez-vous à votre compte |
| `new_expense_title` | New Expense | Nuevo gasto | Nouvelle dépense |
| `no_account_label` | Don't have an account? | ¿No tienes cuenta? | Vous n'avez pas de compte ? |
| `notification_body` | Record your daily expenses... | Registra tus gastos diarios... | Enregistre tes dépenses du jour... |
| `notification_title` | Don't forget your expenses | No olvides tus gastos | N'oublie pas tes dépenses |
| `picker_category` | Select category | Selecciona categoría | Choisir une catégorie |
| `save_button` | Save | Guardar | Enregistrer |
| `search_placeholder` | Search expense... | Buscar gasto… | Rechercher une dépense... |
| `section_amount` | Amount | Cantidad | Montant |
| `section_category` | Category | Categoría | Catégorie |
| `section_details` | Details | Detalles | Détails |
| `signup_button` | Create Account | Crear cuenta | Créer un compte |
| `signup_link` | Sign Up | Regístrate | S'inscrire |
| `signup_subtitle` | Track your expenses | Registra tus gastos | Suivez vos dépenses |
| `signup_title` | Create Account | Crear cuenta | Créer un compte |
| `sync_button` | Sync | Sync | Sync |
| `tab_chart` | Chart | Gráfico | Graphique |
| `tab_expenses` | Expenses | Gastos | Dépenses |
| `total_amount` | Total amount | Importe total | Montant total |

---

## Running Locally

```bash
# Clone the repository
git clone https://github.com/AdrianMalmierca/LedgerlyIOS.git
cd Ledgerly

# Open in Xcode
open Ledgerly.xcodeproj
```

Select a simulator or connected iOS device and press **Run** (⌘R). No additional setup required — the Core Data schema is bundled and the network layer points to a public API that requires no authentication.

### Requirements

- Xcode 15+
- Deployment target iOS 17+
- Swift Package Manager (dependencies resolve automatically on first build)

---

## What I Learned

### Core Data with async/await
Combining Core Data's `viewContext` (bound to the main thread) with Swift's structured concurrency required understanding `@MainActor` as a compile-time guarantee, not a runtime annotation. Annotating the repository with `@MainActor` made the concurrency model explicit and eliminated an entire class of potential threading bugs.

### Combine Pipelines in MVVM
`CombineLatest` was the right operator for merging two independent filter streams, but it required understanding subscription lifetime — storing the `AnyCancellable` in a `Set` is mandatory, not optional. Letting it escape the scope silently cancels the subscription with no error, which was the first bug I had to debug.

### Lottie with UIViewRepresentable
Integrating a UIKit-based animation library into SwiftUI via `UIViewRepresentable` revealed how SwiftUI's layout system differs from UIKit's frame-based model. Setting `translatesAutoresizingMaskIntoConstraints = false` and anchoring the animation view to the container's anchors was the correct pattern — not setting an explicit frame on the Lottie view.

### .xcstrings vs .strings
Xcode 15's `.xcstrings` format is a significant improvement over legacy `.strings` files — keys and translations live in a single JSON file, missing translations are flagged at compile time, and pluralization rules are first-class citizens. Migration from `.strings` is one-way and is worth doing from the start.

### UNUserNotificationCenter Permission Flow
The notification permission request must happen at the right point in the lifecycle — too early (before the first screen loads) and users dismiss it without context; too late and it never fires. Placing the request in the root view's `onAppear`, with a brief explanatory context visible on screen, produced the highest grant rate in testing.

---

## Future Improvements

### Short Term
- **Edit expense** — inline editing of existing expenses on tap
- **Budget limits** — set a monthly cap per category with a warning indicator
- **Export** — share expenses as a CSV file

### Medium Term
- **Widgets** — home screen widget with WidgetKit showing today's total spending

### Long Term
- **Apple Watch app** — quick expense entry from the wrist
- **Recurring expenses** — mark an expense as monthly and insert it automatically

---

## License

MIT — free to use, modify, and deploy.

---

## Author

**Adrián Martín Malmierca**  
Computer Engineer & Master's Student in Mobile Applications  
[GitHub](https://github.com/AdrianMalmierca) · [LinkedIn](https://www.linkedin.com/in/adri%C3%A1n-mart%C3%ADn-malmierca-4aa6b0293/)