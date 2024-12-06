import Foundation
import Combine

enum CallResult: Equatable {
    case success
    case error(String)

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.success, .success):
            return true
        case (.error(let lhs), .error(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }

    var errorMessage: String {
        if case .error(let message) = self {
            return message
        } else {
            return "success"
        }
    }
}

protocol CallService: Hashable {
    init(userAccount: UserAccount)

    var onEvent: AnyPublisher<CallEvent, Never> { get }

    var callState: AnyPublisher<CallState, Never> { get }
    var peerId: String { get }
    var isIncomingCall: Bool { get }
    var isVideoCall: Bool { get }
    var isMyAudioMuted: Bool { get }
    var isPeerAudioMuted: Bool { get }
    var isOnHold: Bool { get }
    var myVideoStream: VideoStream { get }
    var peerVideoStream: VideoStream { get }
    var myMediaStatus: MyMediaStatusObservable { get }
    var callDuration: TimeInterval? { get }

    func registerCallKit()
    @MainActor func makeCall(peerId: String, useVideo: Bool, callStartMessage: String?, accessToken: String) async -> CallResult
    @MainActor func verifyCall(message: PushMessage) async -> CallResult
    func acceptCall()
    func declineCall()
    func endCall(error: Bool)
    func muteMyAudio(mute: Bool)
    func pauseMyVideo(pause: Bool)
    func switchCameraPosition()
    func hold()
    func unhold()
}
