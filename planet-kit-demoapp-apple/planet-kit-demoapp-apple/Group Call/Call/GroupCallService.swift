import Foundation
import Combine

enum GroupCallEvent {
    case didConnect
    case didDisconnect(reason: String)
    case peerListDidUpdate(addedPeers: [any GroupCallPeer], removedPeers: [any GroupCallPeer])
}

enum GroupCallStartFailError: Error {
    case userAcountInvalid
    case internalError(reason: String)
}

protocol GroupCallService {
    init (roomId: String, videoPauseOnStart: Bool, muteOnStart: Bool, settingsService: SettingsService)
    var myUserId: String { get }
    var myName: String { get }
    var roomId: String { get }
    var connectedAt: Date? { get }
    var participantCount: Int { get }

    @MainActor func startGroupCall() async -> Result<Void, GroupCallStartFailError>

    func endGroupCall()
    func pauseMyVideo()
    func resumeMyVideo()
    func muteMyAudio(mute: Bool)
    func switchCameraPosition()

    var peers: [any GroupCallPeer] { get }
    var onEvent: AnyPublisher<GroupCallEvent, Never> { get }
    var myMediaStatus: any MyMediaStatusObservable { get }
    var myVideoStream: any VideoStream { get }
}
