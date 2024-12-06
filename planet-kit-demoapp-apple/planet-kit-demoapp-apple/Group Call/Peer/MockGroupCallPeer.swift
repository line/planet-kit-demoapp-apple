import Foundation
import Combine

class MockGroupCallPeer: GroupCallPeer {
    var id: String {
        userId + created.description
    }

    var name: String
    var isVideoEnabled: Bool
    var userId: String
    var isConnected: Bool
    var isMuted: Bool
    var averageAudioLevel: Int = 0

    var videoStream: VideoStream {
        _videoStream
    }

    private var _videoStream = PlanetVideoStream()

    private let eventSubject = PassthroughSubject<PeerEvent, Never>()
    private let camera = PlanetCamera()
    private let created = Date()
    var onEvent: AnyPublisher<PeerEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    init(id: String, name: String, isConnected: Bool, isVideoEnabled: Bool, isMuted: Bool, averageAudioLevel: Int) {
        self.userId = id
        self.name = name
        self.isConnected = isConnected
        self.isMuted = isMuted
        self.averageAudioLevel = averageAudioLevel
        self.isVideoEnabled = isVideoEnabled
    }

    static func == (lhs: MockGroupCallPeer, rhs: MockGroupCallPeer) -> Bool {
        return lhs.userId == rhs.userId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }

    func disconnect() {
        eventSubject.send(.disconnected)
    }

    func mute(mute: Bool) {
        eventSubject.send(.muted(mute))
    }

    func setVolumeLevel(level: Int) {
        eventSubject.send(.averageAudioLevel(level))
    }

    func startVideo() async -> Bool {
        camera.addStream(stream: _videoStream)
        camera.start()
        return true
    }

    func stopVideo() async -> Bool {
        camera.removeStream(stream: _videoStream)
        camera.stop()
        return true
    }
}
