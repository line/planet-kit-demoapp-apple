import Foundation
import SwiftUI

enum GroupCallJoinViewDestination: Hashable {
    case enterPreview(roomName: String)
    case back
    case home
}

class GroupCallJoinViewModel: ObservableObject {
    @Published var roomName: String = ""
    @Published var showErrorToast: Bool = false

    private var navigationRouter: NavigationRouter?

    private var canRegister: Bool {
        if roomName.count > 0, roomName.count < 21 {
            return true
        } else {
            return false
        }
    }

    func validateRoomName() {
        if roomName.count > AppConstant.maxRoomIdLength {
            roomName = roomName.truncated(maxLength: AppConstant.maxRoomIdLength)
        }

        func isRoomNameFormatValid(roomName: String) -> Bool {
            let regex = "^[a-zA-Z0-9-_]*$"
            return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: roomName)
        }

        while roomName.count > 0, !isRoomNameFormatValid(roomName: roomName) {
            _ = roomName.popLast()
        }
    }

    let settingsService: SettingsService

    init(settingsService: SettingsService) {
        AppLog.v("#demo \(#function) GroupCallJoinViewModel")
        self.settingsService = settingsService
    }

    func enterPreview() {
        guard canRegister else {
            showErrorToast = true
            return
        }
        navigationRouter?.path.append(GroupCallJoinViewDestination.enterPreview(roomName: roomName))
    }

    func navigateBack() {
        navigationRouter?.path.removeLast()
    }

    func navigateHome() {
        navigationRouter?.path.removeLast(2)
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }
}
