import SwiftUI

enum AppTab: CaseIterable, Hashable {
    case home, services, health, finance, pets

    var title: String {
        switch self {
        case .home: "Inicio"
        case .services: "Servicios"
        case .health: "Salud"
        case .finance: "Finanzas"
        case .pets: "Mis mascotas"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .services: "stethoscope"
        case .health: "heart.text.square"
        case .finance: "creditcard"
        case .pets: "pawprint"
        }
    }
}

/// Contenedor principal. Es dueño de los ViewModels de cada pestaña
/// para que conserven su estado al cambiar de pestaña.
struct MainTabView: View {
    let onSignOut: () -> Void

    @State private var selectedTab: AppTab = .home
    @State private var homeViewModel: HomeViewModel
    @State private var servicesViewModel: ServicesViewModel
    @State private var healthViewModel: HealthViewModel
    @State private var financeViewModel: FinanceViewModel
    @State private var petsViewModel: MyPetsViewModel

    init(store: PetCareStore, onSignOut: @escaping () -> Void) {
        self.onSignOut = onSignOut
        _homeViewModel = State(initialValue: HomeViewModel(store: store))
        _servicesViewModel = State(initialValue: ServicesViewModel(store: store))
        _healthViewModel = State(initialValue: HealthViewModel(store: store))
        _financeViewModel = State(initialValue: FinanceViewModel(store: store))
        _petsViewModel = State(initialValue: MyPetsViewModel(store: store))
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch selectedTab {
            case .home:
                HomeView(viewModel: homeViewModel, onSignOut: onSignOut)
            case .services:
                ServicesView(viewModel: servicesViewModel)
            case .health:
                HealthView(viewModel: healthViewModel)
            case .finance:
                FinanceView(viewModel: financeViewModel)
            case .pets:
                MyPetsView(
                    viewModel: petsViewModel,
                    onOpenHealth: { pet in
                        healthViewModel.selectPet(pet.id)
                        selectedTab = .health
                    },
                    onOpenExpenses: { pet in
                        financeViewModel.selectPet(pet.id)
                        selectedTab = .finance
                    }
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selection: $selectedTab)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
        }
    }
}

#Preview {
    MainTabView(store: PreviewData.store, onSignOut: {})
}
