import Foundation
import SwiftUI

enum CallUseCasesViewDestination {
    case basicCall
    case expertConsultation
    case dating
    case mobilityDelivery
    case back
    case home
}

class CallUseCasesViewModel: ObservableObject {
    let availableDestinations: [CallUseCasesViewDestination] = [.basicCall]
    let destinations: [CallUseCasesViewDestination] = [.basicCall, .expertConsultation, .dating, .mobilityDelivery]

    let settingsService: SettingsService
    private var navigationRouter: NavigationRouter?

    init(settingsService: SettingsService) {
        self.settingsService = settingsService
    }

    func navigateTo(destination: CallUseCasesViewDestination) {
        if destination == .basicCall {
            navigationRouter?.path.append(destination)
        } else if destination == .back || destination == .home {
            navigationRouter?.path.removeLast()
        }
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }
}
