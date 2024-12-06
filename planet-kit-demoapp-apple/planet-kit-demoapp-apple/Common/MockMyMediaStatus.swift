import Foundation
import Combine

class MockMyMediaStatus: MyMediaStatusObservable {
    var isMuted: Bool = false
    var isVideoPaused: Bool = false
    var averageAudioLevel: Int = 0
    var onEvent: AnyPublisher<MyMediaStatusEvent, Never> {
        eventSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    private let eventSubject = PassthroughSubject<MyMediaStatusEvent, Never>()

    func testMute(mute: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            AppLog.v("#demo \(#function) event \(mute)")
            self?.isMuted = mute
            self?.eventSubject.send(.muted(mute))
        }
    }

    func testVideoPaused(paused: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            AppLog.v("\(#function)")
            self?.isVideoPaused = paused
            self?.eventSubject.send(.videoPaused(paused))
        }
    }

    func testAverageAudioLevel(level: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.eventSubject.send(.averageAudioLevel(level))
        }
    }
}
