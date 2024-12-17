import Foundation
import Combine

class MockGroupCallService: GroupCallService {
    let myUserId: String
    let myName: String
    let roomId: String
    let videoPauseOnStart: Bool
    let settingsService: SettingsService
    let muteOnStart: Bool

    var connectedAt: Date?

    required init (roomId: String, videoPauseOnStart: Bool, muteOnStart: Bool, settingsService: SettingsService) {
        self.roomId = roomId
        self.videoPauseOnStart = videoPauseOnStart
        self.muteOnStart = muteOnStart
        self.settingsService = settingsService
        self.myUserId = settingsService.userAccount?.userId ?? "error"
        self.myName = settingsService.userAccount?.displayName ?? "error"
    }

    let camera = PlanetCamera()

    var myVideoStream: VideoStream {
        _myVideoStream
    }

    var participantCount: Int {
        peers.count + 1
    }

    private var _myVideoStream = PlanetVideoStream()

    func pauseMyVideo() {
        camera.removeStream(stream: _myVideoStream)
        camera.stop()
        testMyMediaStatus.testVideoPaused(paused: true)
    }

    func resumeMyVideo() {
        camera.addStream(stream: _myVideoStream)
        camera.start()
        testMyMediaStatus.testVideoPaused(paused: false)
    }

    func muteMyAudio(mute: Bool) {
        testMyMediaStatus.testMute(mute: mute)
    }

    func switchCameraPosition() {
    }

    var myMediaStatus: any MyMediaStatusObservable {
        testMyMediaStatus
    }

    private var testMyMediaStatus = MockMyMediaStatus()

    var peers: [any GroupCallPeer] = []

    var onEvent: AnyPublisher<GroupCallEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private let eventSubject = PassthroughSubject<GroupCallEvent, Never>()

    func endGroupCall() {
        camera.removeStream(stream: _myVideoStream)
        camera.stop()
        peers.removeAll()
        eventSubject.send(.peerListDidUpdate(addedPeers: [], removedPeers: peers))
        eventSubject.send(.didDisconnect(reason: "mock"))
    }

    func startGroupCall() async -> Result<Void, GroupCallStartFailError> {
        return await MainActor.run {
            self.peers = [
                MockGroupCallPeer(id: "test1", name: "test1-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0),
                MockGroupCallPeer(id: "test2", name: "test2-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0),
                MockGroupCallPeer(id: "test3", name: "test3-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0),
                MockGroupCallPeer(id: "test4", name: "test4-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0),
                MockGroupCallPeer(id: "test5", name: "test5-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0),
                MockGroupCallPeer(id: "test6", name: "test6-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0),
                MockGroupCallPeer(id: "test7", name: "test7-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0),
                MockGroupCallPeer(id: "test8", name: "test8-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0)
            ]

            connectedAt = .now
            eventSubject.send(.didConnect)
            eventSubject.send(.peerListDidUpdate(addedPeers: peers, removedPeers: []))
            return .success(())
        }
    }

    func addPeer() {
        let newPeer = MockGroupCallPeer(id: "test\(peers.count)", name: "test\(peers.count)-name", isConnected: true, isVideoEnabled: false, isMuted: false, averageAudioLevel: 0)
        peers.append(newPeer)
        eventSubject.send(.peerListDidUpdate(addedPeers: [newPeer], removedPeers: []))
    }

    func removePeer() {
        guard peers.count > 0 else {
            return
        }
        let removed = peers.removeLast()
        eventSubject.send(.peerListDidUpdate(addedPeers: [], removedPeers: [removed]))
    }

    func testAverageAudioLevel(level: Int) {
        testMyMediaStatus.testAverageAudioLevel(level: level)
    }
}
