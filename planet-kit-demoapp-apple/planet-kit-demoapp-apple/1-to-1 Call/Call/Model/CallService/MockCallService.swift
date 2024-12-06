import Foundation
import Combine

class MockCallService: NSObject, CallService {
    required init(userAccount: UserAccount) {
    }

    var onEvent: AnyPublisher<CallEvent, Never> {
        subject.eraseToAnyPublisher()
    }

    var callState: AnyPublisher<CallState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var peerId: String {
        return "test_peer_id"
    }

    var isIncomingCall: Bool = true

    var isVideoCall: Bool {
        return true
    }

    var isMyAudioMuted: Bool {
        return true
    }

    var isPeerAudioMuted: Bool {
        return true
    }

    var isOnHold: Bool {
        return false
    }

    var myVideoStream: VideoStream {
        _myVideoStream
    }

    var peerVideoStream: VideoStream {
        _peerVideoStream
    }

    var myMediaStatus: MyMediaStatusObservable {
        _myMediaStatus
    }

    var callDuration: TimeInterval? {
        guard let startTime = callStartTime else {
            return nil
        }
        if let endTime = callEndTime {
            return startTime.distance(to: endTime)
        } else {
            return startTime.distance(to: Date())
        }
    }

    private var _myVideoStream = PlanetVideoStream()
    private var _peerVideoStream = PlanetVideoStream()
    private var _myMediaStatus = MockMyMediaStatus()
    private let subject = PassthroughSubject<CallEvent, Never>()
    private let stateSubject = CurrentValueSubject<CallState, Never>(.trying)

    private var makeCallResult: CallResult = .success
    private var verifyCallResult: CallResult = .success
    private var callStartTime: Date?
    private var callEndTime: Date?

    func registerCallKit() {
    }

    @MainActor
    func makeCall(peerId: String, useVideo: Bool, callStartMessage: String?, accessToken: String) async -> CallResult {
        isIncomingCall = false
        stateSubject.send(.connecting)
        return makeCallResult
    }

    @MainActor
    func verifyCall(message: PushMessage) async -> CallResult {
        isIncomingCall = true
        stateSubject.send(.connecting)
        return verifyCallResult
    }

    func acceptCall() {
    }

    func declineCall() {
    }

    func endCall(error: Bool) {
    }

    func muteMyAudio(mute: Bool) {
    }

    func pauseMyVideo(pause: Bool) {
    }

    func switchCameraPosition() {
    }

    func hold() {
    }

    func unhold() {
    }
}

// MARK: Mock control API
extension MockCallService {
    func connected() {
        subject.send(.onConnected)
        stateSubject.send(.connected)
        callStartTime = Date()
        callEndTime = nil
    }

    func disconnected(reason: String = "normal") {
        subject.send(.onDisconnected(reason))
        stateSubject.send(.disconnected(reason: reason))
        callEndTime = Date()
    }

    func setIncomingCall() {
        isIncomingCall = true
    }

    func reserveMakeCallError(_ error: String) {
        makeCallResult = .error(error)
    }

    func reserveVerifyCallFailure(_ error: String) {
        verifyCallResult = .error(error)
    }
}
