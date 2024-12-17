import SwiftUI
import Combine

class AudioCallViewModel: CallViewModel {
    @Published var isAudioDevicePopup: Bool = false

    private var cancellables = Set<AnyCancellable>()

    override init(callService: any CallService) {
        super.init(callService: callService)
    }

    func toggleMute() {
        if isMyAudioMuted {
            callService.muteMyAudio(mute: false)
        } else {
            callService.muteMyAudio(mute: true)
        }
        isMyAudioMuted.toggle()
    }

    func pickAudioDevice() {
        isAudioDevicePopup = true
    }
}
