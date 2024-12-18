import Foundation
import Combine
import PlanetKit

class PlanetMyMediaStatus: MyMediaStatusObservable {
    var isMuted: Bool
    var isVideoPaused: Bool
    var averageAudioLevel: Int = 0
    var onEvent: AnyPublisher<MyMediaStatusEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(isVideoPaused: Bool, isMuted: Bool, averageAudioLevel: Int) {
        self.isVideoPaused = isVideoPaused
        self.isMuted = isMuted
        self.averageAudioLevel = averageAudioLevel
    }

    private let eventSubject = PassthroughSubject<MyMediaStatusEvent, Never>()
}

extension PlanetMyMediaStatus: PlanetKitMyMediaStatusDelegate {
    func didMuteMic(_ myMediaStatus: PlanetKitMyMediaStatus) {
        DispatchQueue.main.async { [weak self] in
            self?.isMuted = true
            self?.eventSubject.send(.muted(true))
        }
    }

    func didUnmuteMic(_ myMediaStatus: PlanetKitMyMediaStatus) {
        DispatchQueue.main.async { [weak self] in
            self?.isMuted = false
            self?.eventSubject.send(.muted(false))
        }
    }

    func didUpdateAudioDescription(_ myMediaStatus: PlanetKitMyMediaStatus, description: PlanetKitMyAudioDescription) {
        DispatchQueue.main.async { [weak self] in
            self?.averageAudioLevel = Int(description.averageVolumeLevel)
            self?.eventSubject.send(.averageAudioLevel(Int(description.averageVolumeLevel)))
        }
    }

    func didUpdateVideoStatus(_ myMediaStatus: PlanetKitMyMediaStatus, status: PlanetKitVideoStatus) {
        AppLog.v("\(#function)")
        DispatchQueue.main.async { [weak self] in
            let isPaused = status.isPausedOrDisabled
            self?.isVideoPaused = isPaused
            self?.eventSubject.send(.videoPaused(isPaused))
        }
    }
}
