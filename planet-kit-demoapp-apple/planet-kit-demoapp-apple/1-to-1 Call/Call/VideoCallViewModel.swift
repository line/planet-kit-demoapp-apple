import SwiftUI
import Combine

enum VideoState {
    case on
    case off
}

class VideoCallViewModel: CallViewModel {
    @Published var isAudioDevicePopup: Bool = false
    @Published var isVideoDevicePopup: Bool = false

    @Published var isMyVideoPaused: Bool = false
    @Published var isPeerVideoPaused: Bool = false
    @Published var isFirstPeerVideoRendered: Bool = false
    @Published var isCameraUnauthorized: Bool = false

    var myVideoStream: VideoStream {
        callService.myVideoStream
    }

    var peerVideoStream: VideoStream {
        callService.peerVideoStream
    }

    private var deviceAuthService = AppleDeviceAuthorizationService()
    private var cancellables = Set<AnyCancellable>()
    private var callEndRecordManager: CallEndRecordManager?

    override init(callService: any CallService) {
        super.init(callService: callService)

        callService.onEvent
            .sink { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .onConnected:
                    checkAccessForCamera()
                case .onPeerVideoPaused:
                    isPeerVideoPaused = true
                case .onPeerVideoResumed:
                    isPeerVideoPaused = false
                default:
                    break
                }
            }
            .store(in: &cancellables)

        callService.myMediaStatus.onEvent
            .sink { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .videoPaused(let paused):
                    isMyVideoPaused = paused
                default:
                    break
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
                    self?.isMyVideoPaused = true
                }
            }
            .store(in: &cancellables)
    }

    func checkAccessForCamera() {
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            isCameraUnauthorized = !(await deviceAuthService.authorizationStatus(for: .camera))
            if isCameraUnauthorized {
                callService.pauseMyVideo(pause: true)
            }
        }
    }

    func appearMyVideo() {
        PlanetCamera().start()
    }

    func disappearMyVideo() {
        PlanetCamera().stop()
    }

    func toggleMute() {
        if isMyAudioMuted {
            callService.muteMyAudio(mute: false)
        } else {
            callService.muteMyAudio(mute: true)
        }
        isMyAudioMuted.toggle()
    }

    func togglePause() {
        if isMyVideoPaused {
            callService.pauseMyVideo(pause: false)
        } else {
            callService.pauseMyVideo(pause: true)
        }
        isMyVideoPaused.toggle()
    }

    func pickAudioDevice() {
        isAudioDevicePopup = true
    }

    func pickVideoDevice() {
        isVideoDevicePopup = true
    }

    func switchCameraPosition() {
        callService.switchCameraPosition()
    }

    func didRenderFirstPeerVideo() {
        isFirstPeerVideoRendered = true
    }

    func openAppSettingsForCamera() {
        deviceAuthService.openAppSettings(for: .camera)
    }

    override func navigateWithCallState(state: CallState) {
        super.navigateWithCallState(state: state)

        if case .disconnected = callState {
            PlanetCamera().resetCurrentDevice()
        }
    }
}
