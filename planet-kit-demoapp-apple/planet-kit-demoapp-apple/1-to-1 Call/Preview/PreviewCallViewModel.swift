import SwiftUI
import Combine

class PreviewCallViewModel: ObservableObject {

    @Published var peerId: String = ""

    @Published var isAccepted: Bool = false
    @Published var isDeclined: Bool = false

    @Published var isMuted: Bool = false
    @Published var isPaused: Bool = false

    @Published var isAudioDevicePopup: Bool = false
    @Published var isVideoDevicePopup: Bool = false

    @Published var callState: CallState = .connecting

    let callService: any CallService
    let myVideoStream: VideoStream
    private var callEndRecordManager: CallEndRecordManager?
    private var navigationRouter: NavigationRouter?

    private var cancellables = Set<AnyCancellable>()

    init(callService: any CallService) {
        self.callService = callService
        peerId = callService.peerId
        myVideoStream = callService.myVideoStream

        AppLog.v("#vs PreviewCallViewModel - myVideoStream")

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
                    isAccepted = true
                case .onDisconnected:
                    isDeclined = true
                default: ()
                }
            }
            .store(in: &cancellables)
    }

    func bindVideoDeviceService(_ service: VideoDeviceService) {
        service.onDisconnected
            .sink { [weak self] device in
                // If the camera in use gets disconnected, it will automatically perform a pauseMyVideo().
                if device.isUsed {
                    self?.callService.pauseMyVideo(pause: true)
                    self?.isPaused = true
                }
            }
            .store(in: &cancellables)
    }

    func appearPreview() {
        if !isPaused {
            PlanetCamera().start()
            AppLog.v("#vs camera start")
        }
    }

    func disappearPreview() {
        if isPaused {
            PlanetCamera().stop()
            AppLog.v("#vs camera stop")
        }
    }

    func toggleMute() {
        if isMuted {
            callService.muteMyAudio(mute: false)
        } else {
            callService.muteMyAudio(mute: true)
        }
        isMuted.toggle()
    }

    func togglePause() {
        if isPaused {
            callService.pauseMyVideo(pause: false)
        } else {
            callService.pauseMyVideo(pause: true)
        }
        isPaused.toggle()
    }

    func pickAudioDevice() {
        isAudioDevicePopup = true
    }

    func pickVideoDevice() {
        isVideoDevicePopup = true
    }

    func setCallEndRecordManager(manager: CallEndRecordManager?) {
        callEndRecordManager = manager
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }

    func navigateWithCallState(state: CallState) {
        AppLog.v("#demoapp \(#function) state: \(state)")
        if case .disconnected(let reason) = state {
            PlanetCamera().stop()
            PlanetCamera().resetCurrentDevice()
            callEndRecordManager?.records.append(CallEndRecord(callType: .oneToOneCall(peerId), disconnectReason: reason))
            guard let navigationRouter = navigationRouter else { return }
            navigationRouter.path.removeLast(navigationRouter.path.count)
        }
    }
}
