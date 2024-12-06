import Foundation
import Combine

class GroupCallMyViewViewModel: ObservableObject {

    @Published var isSpeaking: Bool
    @Published var isMuted: Bool
    @Published var isVideoPaused: Bool

    let userId: String
    let name: String
    let myVideoStream: any VideoStream

    private var mediaStatus: any MyMediaStatusObservable
    private var cancellables = Set<AnyCancellable>()

    init(userId: String, name: String, myMediaStatus: any MyMediaStatusObservable, myVideoStream: any VideoStream) {
        isMuted = myMediaStatus.isMuted
        isVideoPaused = myMediaStatus.isVideoPaused
        isSpeaking = (myMediaStatus.averageAudioLevel > PlanetConstant.speechAudioLevelThreshold && myMediaStatus.isMuted == false)

        self.userId = userId
        self.name = name
        self.mediaStatus = myMediaStatus
        self.myVideoStream = myVideoStream
        bindService()
    }

    private func bindService() {
        mediaStatus.onEvent
            .sink { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .muted(let mute):
                    isMuted = mute
                case .videoPaused(let paused):
                    isVideoPaused = paused
                case .averageAudioLevel(let level):
                    isSpeaking = (level > PlanetConstant.speechAudioLevelThreshold && isMuted == false)
                }
            }
            .store(in: &cancellables)
    }
}
