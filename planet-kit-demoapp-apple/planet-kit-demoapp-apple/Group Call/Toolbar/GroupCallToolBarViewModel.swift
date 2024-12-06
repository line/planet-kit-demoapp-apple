import SwiftUI
import Combine

class GroupCallToolBarViewModel: ObservableObject {
    @Published var isMuted: Bool
    @Published var isVideoPaused: Bool

    @Published var participantCount = 0

    @Published var isAudioDevicePopup: Bool = false
    @Published var isVideoDevicePopup: Bool = false

    private var control: GroupCallToolBarControl
    private var cancellables = Set<AnyCancellable>()

    init(control: GroupCallToolBarControl) {
        isMuted = control.isMuted
        isVideoPaused = control.isVideoPaused
        participantCount = control.participantCount
        self.control = control
        bindService()
    }

    func toggleMute() {
        isMuted.toggle()
        control.muteMyAudio(mute: isMuted)
    }

    func toggleVideo() {
        if isVideoPaused {
            control.resumeMyVideo()
        } else {
            control.pauseMyVideo()
        }

        isVideoPaused.toggle()
    }

    func leaveGroupCall() {
        control.leaveGroupCall()
    }

    func switchCamera() {
        control.switchCamera()
    }

    func pickVideoDevice() {
        isVideoDevicePopup.toggle()
    }

    func pickAudioDevice() {
        isAudioDevicePopup.toggle()
    }

    private func bindService() {
        control.onEvent
            .sink { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .muted(let mute):
                    self.isMuted = mute
                case .videoPaused(let paused):
                    self.isVideoPaused = paused
                case .participantCountUpdated:
                    self.participantCount = self.control.participantCount
                }
            }
            .store(in: &cancellables)
    }
}
