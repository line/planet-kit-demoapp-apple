import Foundation
import Combine

enum PeerEvent {
    case disconnected
    case muted(Bool)
    case videoEnabled(Bool)
    case averageAudioLevel(Int)
}

protocol GroupCallPeer {
    var userId: String { get }
    var name: String { get }
    var onEvent: AnyPublisher<PeerEvent, Never> { get }
    var isConnected: Bool { get }
    var isMuted: Bool { get }
    var isVideoEnabled: Bool { get }
    var averageAudioLevel: Int { get }

    var id: String { get }
    var videoStream: VideoStream { get }
    @MainActor func startVideo() async -> Bool
    @MainActor func stopVideo() async -> Bool
}
