import Foundation
import Combine
import SwiftUI

enum GroupCallState: Equatable {
    case trying
    case connected
    case disconnected(reason: String)
    case startFailed(reason: String)
}

extension GroupCallState: CustomStringConvertible {
    var description: String {
        switch self {
        case .trying: return "trying"
        case .connected: return "connected"
        case .disconnected: return "disconnected"
        case .startFailed: return "startFailed"
        }
    }
}

class GroupCallViewModel: ObservableObject {
    @Published var callState: GroupCallState = .trying
    @Published var peers: [any GroupCallPeer] = []
    @Published var disconnectedPeers: [String] = []
    @Published var duration: String = "00:00:00"
    @Published var isCameraUnauthorized: Bool = false

    private var callEndRecordManager: CallEndRecordManager?
    private var navigationRouter: NavigationRouter?

    private var cancellable: AnyCancellable?

    var roomId: String {
        service.roomId
    }

    var participantCount: Int {
        service.participantCount
    }

    let myUserId: String
    let myName: String
    let myMediaStatus: any MyMediaStatusObservable
    let service: any GroupCallService

    private var cancellables = Set<AnyCancellable>()
    private let formatter: DateFormatter

    private var deviceAuthService = AppleDeviceAuthorizationService()

    init(service: any GroupCallService) {
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.myUserId = service.myUserId
        self.myName = service.myName
        self.service = service
        self.myMediaStatus = service.myMediaStatus

        service.onEvent
            .sink { [weak self] event in
                guard let `self` = self else { return }
                AppLog.v("#demo GroupCallViewModel \(event)")
                switch event {
                case .didConnect:
                    callState = .connected
                    startTimer()
                    checkAccessForCamera()
                case .didDisconnect(let reason):
                    callState = .disconnected(reason: reason)
                    stopTimer()
                case .peerListDidUpdate(_, let removedPeers):
                    disconnectedPeers.append(contentsOf: removedPeers.map({$0.name}))
                    peers = service.peers
                }
            }
            .store(in: &cancellables)
    }

    func setCallEndRecordManager(manager: CallEndRecordManager?) {
        callEndRecordManager = manager
    }

    func bindVideoDeviceService(_ service: VideoDeviceService) {
        service.onDisconnected
            .sink { [weak self] device in
                // If the camera in use gets disconnected, it will automatically perform a pauseMyVideo().
                if device.isUsed {
                    self?.service.pauseMyVideo()
                }
            }
            .store(in: &cancellables)
    }

    func navigateWithCallState(callState: GroupCallState) {
        switch callState {
        case .disconnected(let reason):
            PlanetCamera().resetCurrentDevice()
            callEndRecordManager?.records.append(CallEndRecord(callType: .groupCall(roomId), disconnectReason: reason))
            guard let navigationRouter = navigationRouter else { return }
            navigationRouter.path.removeLast(navigationRouter.path.count)
        case .startFailed:
            navigationRouter?.path.removeLast(2)
        default:
            break
        }
    }

    func startTimer() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = `self`, let connectedAt = service.connectedAt else { return }
                let elapsedTime = Date().timeIntervalSince(connectedAt)
                self.duration = elapsedTime.toHHMMSS()
            }
    }

    func clearDisconnectedPeers() {
        disconnectedPeers.removeAll()
    }

    func stopTimer() {
        cancellable?.cancel()
    }

    func startGroupCall() {
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            let result = await service.startGroupCall()
            switch result {
            case .success:
                // do nothing on start success
                break
            case .failure(let error):
                switch error {
                case .internalError(let reason):
                    callState = .startFailed(reason: reason)
                case .userAcountInvalid:
                    callState = .startFailed(reason: "userAcountInvalid")
                }
            }
        }
    }

    func endGroupCall() {
        service.endGroupCall()
    }

    func checkAccessForCamera() {
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            isCameraUnauthorized = !(await deviceAuthService.authorizationStatus(for: .camera))
            if isCameraUnauthorized {
                service.pauseMyVideo()
            }
        }
    }

    func openAppSettingsForCamera() {
        deviceAuthService.openAppSettings(for: .camera)
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }
}

extension TimeInterval {
    func toHHMMSS() -> String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
