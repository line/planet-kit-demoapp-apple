import SwiftUI
import Combine

enum MakeCallViewDestination: Hashable {
    case audioCall(Any)
    case videoCall(Any)
    case home
    case back

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.audioCall(lhsType), .audioCall(rhsType)),
             let (.videoCall(lhsType), .videoCall(rhsType)):
            guard let l = lhsType as? (any CallService),
                  let r = rhsType as? (any CallService) else {
                return false
            }
            return l.hashValue == r.hashValue
        case (.home, .home),
             (.back, .back):
            return true
        default: return false
        }
    }
}

class MakeCallViewModel: ObservableObject {
    @Published var peerId: String = ""

    let settingsService: SettingsService
    let callService: any CallService

    @Published var startRecord: CallStartRecord?

    private var navigationRouter: NavigationRouter?
    private var cancellables = Set<AnyCancellable>()

    var isPeerIdValid: Bool {
        !peerId.isEmpty && peerId.utf8.count <= 64
    }

    init(settingsService: SettingsService, callService: any CallService) {
        self.settingsService = settingsService
        self.callService = callService
    }

    func makeCall(useVideo: Bool) {
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            let result = await makeCall(useVideo: useVideo)
            switch result {
            case .success:
                if useVideo {
                    navigateTo(destination: .videoCall(callService))
                } else {
                    navigateTo(destination: .audioCall(callService))
                }
            case .error(let reason):
                startRecord = CallStartRecord(callType: .oneToOneCall(peerId), startFailReason: reason)
            }
        }
    }

    func navigateToBack() {
        navigateTo(destination: .back)
    }

    func navigateToHome() {
        navigateTo(destination: .home)
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }

    func validatePeerId() {
        var validPeerId = peerId
        if validPeerId.count > AppConstant.maxPeerIdLength {
            validPeerId = validPeerId.truncated(maxLength: AppConstant.maxPeerIdLength)
        }

        func isPeerIdFormatValid(peerId: String) -> Bool {
            let regex = "^[a-zA-Z0-9-_]*$"
            return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: peerId)
        }

        while validPeerId.count > 0, !isPeerIdFormatValid(peerId: validPeerId) {
            _ = validPeerId.popLast()
        }
        peerId = validPeerId
    }
    
    @MainActor
    private func makeCall(useVideo: Bool) async -> CallResult {
        guard isPeerIdValid else {
            return .error(CallStartRecord.invalidUserIdReason)
        }
        guard let accessToken = await settingsService.getAccessToken() else {
            return .error(CallStartRecord.invalidAccessTokenReason)
        }
        AppLog.v("accessToken: \(accessToken)")

        callService.registerCallKit()

        return await callService.makeCall(peerId: peerId, useVideo: useVideo, callStartMessage: nil, accessToken: accessToken)
    }

    private func navigateTo(destination: MakeCallViewDestination) {
        guard let navigationRouter = navigationRouter else { return }
        switch destination {
        case .audioCall, .videoCall:
            navigationRouter.path.append(destination)
        case .home:
            navigationRouter.path.removeLast(navigationRouter.path.count)
        case .back:
            navigationRouter.path.removeLast()
        }
    }
}
