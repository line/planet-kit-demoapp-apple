import Foundation
import Combine

enum MyMediaStatusEvent {
    case muted(Bool)
    case videoPaused(Bool)
    case averageAudioLevel(Int)
}

protocol MyMediaStatusObservable {
    var isMuted: Bool { get }
    var isVideoPaused: Bool { get }
    var averageAudioLevel: Int { get }
    var onEvent: AnyPublisher<MyMediaStatusEvent, Never> { get }
}
