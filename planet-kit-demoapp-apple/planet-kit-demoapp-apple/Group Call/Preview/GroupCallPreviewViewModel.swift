import Combine
import SwiftUI

enum GroupCallPreviewDestination: Hashable {
    struct EnterRoomParam: Hashable {
        let roomName: String
        let videoPauseOnStart: Bool
        let muteOnStart: Bool
    }
    case enterRoom(param: EnterRoomParam)
}

class GroupCallPreviewViewModel: ObservableObject {
    @Published var isMuted: Bool = false
    @Published var isVideoEnabled: Bool = true
    @Published var isAudioDevicePopup: Bool = false
    @Published var isVideoDevicePopup: Bool = false

    let roomName: String
    let settingsService: SettingsService
    private let previewService: CameraPreviewService
    private var cancellables = Set<AnyCancellable>()
    private var navigationRouter: NavigationRouter?

    var stream: VideoStream {
        previewService.stream
    }

    init(roomName: String, previewService: CameraPreviewService, settingsService: SettingsService) {
        self.roomName = roomName
        self.previewService = previewService
        self.settingsService = settingsService
    }

    func bindVideoDeviceService(_ service: VideoDeviceService) {
        service.onDisconnected
            .sink { [weak self] device in
                // If the camera in use gets disconnected, it will automatically perform a pauseMyVideo().
                if device.isUsed {
                    self?.stopPreview()
                    self?.isVideoEnabled = false
                }
            }
            .store(in: &cancellables)
    }

    func toggleMute() {
        isMuted.toggle()
    }

    func toggleVideo() {
        if isVideoEnabled {
            stopPreview()
        } else {
            startPreview()
        }
        isVideoEnabled.toggle()
    }

    func enterRoom() {
        navigationRouter?.path.append(GroupCallPreviewDestination.enterRoom(param: .init(roomName: roomName, videoPauseOnStart: !isVideoEnabled, muteOnStart: isMuted)))
    }

    func exit() {
        previewService.stop()
        navigationRouter?.path.removeLast()
    }

    func startPreview() {
        previewService.start()
    }

    func stopPreview() {
        previewService.stop()
    }

    func pickVideoDevice() {
        isVideoDevicePopup.toggle()
    }

    func pickAudioDevice() {
        isAudioDevicePopup.toggle()
    }

    #if os(iOS)
    func toggleCameraPosition() {
        previewService.switchCameraPosition()
    }
    #endif

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }
}
