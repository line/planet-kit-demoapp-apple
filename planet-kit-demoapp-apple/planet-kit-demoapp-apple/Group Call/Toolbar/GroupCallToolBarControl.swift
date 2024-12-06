import Foundation
import Combine

enum GroupCallToolbarEvent {
    case videoPaused(Bool)
    case muted(Bool)
    case participantCountUpdated
}

class GroupCallToolBarControl {
    var isMuted: Bool
    var isVideoPaused: Bool

    private let eventSubject = PassthroughSubject<GroupCallToolbarEvent, Never>()
    private var cancellables = Set<AnyCancellable>()

    var onEvent: AnyPublisher<GroupCallToolbarEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    var participantCount: Int {
        return service.participantCount
    }

    private let service: any GroupCallService

    init(groupCallService: any GroupCallService) {
        self.isMuted = groupCallService.myMediaStatus.isMuted
        self.isVideoPaused = groupCallService.myMediaStatus.isVideoPaused
        self.service = groupCallService
        bind(groupCallService: groupCallService)
    }

    func bind(groupCallService: GroupCallService) {
        groupCallService.onEvent.sink { [weak self] event in
            switch event {
            case .peerListDidUpdate:
                self?.eventSubject.send(.participantCountUpdated)
            default:
                break
            }
        }
        .store(in: &cancellables)

        groupCallService.myMediaStatus.onEvent
            .sink { [weak self] event in
                switch event {
                case .muted(let mute):
                    self?.isMuted = mute
                    self?.eventSubject.send(.muted(mute))
                case .videoPaused(let paused):
                    self?.isVideoPaused = paused
                    self?.eventSubject.send(.videoPaused(paused))
                case .averageAudioLevel:
                    break
                }
            }
            .store(in: &cancellables)
    }

    func pauseMyVideo() {
        service.pauseMyVideo()
    }

    func resumeMyVideo() {
        service.resumeMyVideo()
    }

    func muteMyAudio(mute: Bool) {
        service.muteMyAudio(mute: mute)
    }

    func switchCamera() {
        service.switchCameraPosition()
    }

    func leaveGroupCall() {
        AppLog.v("#demo toobar \(#function)")
        service.endGroupCall()
    }
}
