import SwiftUI
import Combine

enum CallState: Equatable {
    case trying
    case connecting
    case connected
    case disconnected(reason: String)

    static func == (lhs: CallState, rhs: CallState) -> Bool {
        switch (lhs, rhs) {
        case (.trying, .trying),
             (.connecting, .connecting),
             (.connected, .connected):
            return true
        case (.disconnected(let lhsReason), .disconnected(let rhsReason)):
            return lhsReason == rhsReason
        default:
            return false
        }
    }
}

enum CallType: Equatable {
    case oneToOneCall(_ peerId: String)
    case groupCall(_ roomId: String)
}

struct CallStartRecord: Equatable {
    let callType: CallType
    let startFailReason: String

    static func == (lhs: CallStartRecord, rhs: CallStartRecord) -> Bool {
        return lhs.callType == rhs.callType && lhs.startFailReason == rhs.startFailReason
    }

    static let testCallRecord = CallStartRecord(callType: .oneToOneCall(UserAccount.testAccount.userId), startFailReason: "Unknown")

    // Predefined reason error code
    static let invalidUserIdReason = "invalidUserId"
    static let invalidAccessTokenReason = "Invalid access token"
    static let invalidCallReason = "Invalid Call"
    static let invalidCCParamReason = "Invalid CCParam"
    static let myMediaStatusErrorReason = "MyMediaStatus Error"
    static let callKitErrorReason = "CallKit Error"
}

struct CallEndRecord: Equatable {
    let callType: CallType
    let disconnectReason: String

    static func == (lhs: CallEndRecord, rhs: CallEndRecord) -> Bool {
        return lhs.callType == rhs.callType && lhs.disconnectReason == rhs.disconnectReason
    }

    static let testCallRecord = CallEndRecord(callType: .oneToOneCall(UserAccount.testAccount.userId), disconnectReason: "Normal")
}

class CallViewModel: ObservableObject {

    @Published var peerId: String = ""
    @Published var stateMessage: String = ""

    @Published var callState: CallState = .connecting
    @Published var isMyAudioMuted: Bool = false
    @Published var isPeerAudioMuted: Bool = false
    @Published var isUserSpeaking: Bool = false
    @Published var isPeerSpeaking: Bool = false

    var isIncomingCall: Bool {
        callService.isIncomingCall
    }

    let callService: any CallService
    private var callEndRecordManager: CallEndRecordManager?
    private var navigationRouter: NavigationRouter?
    private var callStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    init(callService: any CallService) {
        self.callService = callService
        self.peerId = callService.peerId
        self.isMyAudioMuted = callService.isMyAudioMuted
        self.isPeerAudioMuted = callService.isPeerAudioMuted

        callService.callState
            .sink { [weak self] newState in
                self?.callState = newState
            }
            .store(in: &cancellables)

        callService.onEvent
            .sink { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .onConnected:
                    callStartTime = Date()
                case .onPeerMicMuted:
                    isPeerAudioMuted = true
                case .onPeerMicUnmuted:
                    isPeerAudioMuted = false
                case .onPeerAverageAudioLevel(let level):
                    isPeerSpeaking = (level > PlanetConstant.speechAudioLevelThreshold)
                default:
                    break
                }
            }
            .store(in: &cancellables)

        callService.myMediaStatus.onEvent
            .sink { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .muted(let mute):
                    isMyAudioMuted = mute
                case .averageAudioLevel(let level):
                    isUserSpeaking = (level > PlanetConstant.speechAudioLevelThreshold)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func accept() {
        callService.acceptCall()
    }

    func disconnect() {
        if isIncomingCall {
            switch callState {
            case .trying, .connecting:
                callService.declineCall()
            case .connected:
                callService.endCall(error: false)
            case .disconnected:
                break
            }
        } else {
            callService.endCall(error: false)
        }
    }

    func setCallEndRecordManager(manager: CallEndRecordManager?) {
        callEndRecordManager = manager
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }

    func navigateWithCallState(state: CallState) {
        AppLog.v("#demoapp \(#function) state: \(state)")
        if case .disconnected(let reason) = callState {
            callEndRecordManager?.records.append(CallEndRecord(callType: .oneToOneCall(peerId), disconnectReason: reason))
            guard let navigationRouter = navigationRouter else { return }
            navigationRouter.path.removeLast(navigationRouter.path.count)
        }
    }
}

extension TimeInterval {
    var timeString: String {
        let seconds = Int(self)
        let minutes = seconds / 60
        let hours = minutes / 60
        let remainSeconds = seconds % 60
        let remainMinutes = minutes % 60
        if hours > 0 {
            return String(format: "%d:%.2d:%.2d", hours, remainMinutes, remainSeconds)
        } else {
            return String(format: "%d:%.2d", remainMinutes, remainSeconds)
        }
    }
}
