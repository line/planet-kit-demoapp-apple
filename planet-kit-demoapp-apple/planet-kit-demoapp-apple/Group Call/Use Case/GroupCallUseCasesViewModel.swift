import Foundation
import SwiftUI

enum GroupCallUseCasesViewDestination {
    case basic
    case socialAndCommunity
    case onlineEducation
    case remoteWork
    case gameAndMetaverse
    case back
}

class GroupCallUseCasesViewModel: ObservableObject {
    let availableDestinations: [GroupCallUseCasesViewDestination] = [.basic]
    let destinations: [GroupCallUseCasesViewDestination] = [.basic, .socialAndCommunity, .onlineEducation, .remoteWork, .gameAndMetaverse]

    let settingsService: SettingsService
    private var navigationRouter: NavigationRouter?

    init(settingsService: SettingsService) {
        self.settingsService = settingsService
    }

    func navigateTo(destination: GroupCallUseCasesViewDestination) {
        // do some checks and preps for each types
        if destination == .basic {
            navigationRouter?.path.append(GroupCallUseCasesViewDestination.basic)
        } else if destination == .back {
            navigationRouter?.path.removeLast()
        }
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }
}
