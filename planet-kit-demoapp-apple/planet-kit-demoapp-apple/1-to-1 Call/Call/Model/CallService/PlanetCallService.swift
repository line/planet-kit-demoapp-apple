import Combine
import PlanetKit

class PlanetCallService: NSObject, CallService {

    private var call: PlanetKitCall?

    private let callKitService = CallKitService()
    private let userAccount: UserAccount
    private var callStartTime: Date?
    private var callEndTime: Date?

    private let subject = PassthroughSubject<CallEvent, Never>()
    private let stateSubject = CurrentValueSubject<CallState, Never>(.trying)

    var onEvent: AnyPublisher<CallEvent, Never> {
        subject.eraseToAnyPublisher()
    }

    var callState: AnyPublisher<CallState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    private(set) var peerId: String = "<unknown>"

    private(set) var isIncomingCall: Bool = false

    var isVideoCall: Bool {
        call?.mediaType.hasVideo == true
    }

    var isMyAudioMuted: Bool {
        call?.isMyAudioMuted ?? false
    }

    var isPeerAudioMuted: Bool {
        call?.isPeerAudioMuted ?? false
    }

    var isOnHold: Bool {
        call?.isOnHold ?? false
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
    private var _myMediaStatus = PlanetMyMediaStatus(isVideoPaused: false, isMuted: false, averageAudioLevel: 0)

    required init(userAccount: UserAccount) {
        self.userAccount = userAccount
    }

    func registerCallKit() {
        #if os(iOS)
        try? callKitService.register()
        #endif
    }

    @MainActor
    func makeCall(peerId: String, useVideo: Bool, callStartMessage: String?, accessToken: String) async -> CallResult {
        guard call == nil else {
            return .error("Invalid Call")
        }

        let settings = try! PlanetKitMakeCallSettingBuilder()
            .withResponseOnEnableVideo(response: .pause)
            .withCustomCameraStreamKey(videoStream: _myVideoStream.videoStream)
            .withSetRingbackToneKey(fileResourceUrl: Bundle.main.url(forResource: "48k-Ringback", withExtension: "wav")!)
            .withSetEndToneKey(fileResourceUrl: Bundle.main.url(forResource: "48k-End", withExtension: "wav")!)
            .withSetHoldToneKey(fileResourceUrl: Bundle.main.url(forResource: "48k-Hold", withExtension: "wav")!)
            .withEnableStatisticsKey(enable: true)
            #if os(iOS)
            .withCallKitSettingsKey(setting: PlanetKitCallKitSetting(type: .user, param: nil))
            #endif
            .build()

        let myUserId = PlanetKitUserId(id: userAccount.userId, serviceId: userAccount.serviceId)
        let peerUserId = PlanetKitUserId(id: peerId, serviceId: userAccount.serviceId)

        let param = PlanetKitCallParam(myUserId: myUserId, peerUserId: peerUserId, delegate: self, accessToken: accessToken)
        param.mediaType = (useVideo ? .audiovideo: .audio)
        param.useResponderPreparation = false
        param.startMessage = (callStartMessage != nil ? PlanetKitCallStartMessage(data: callStartMessage!): nil)
        param.recordOnCloud = false

        let result = PlanetKitManager.shared.makeCall(param: param, settings: settings)

        guard result.reason == .none, let call = result.call else {
            AppLog.v("#demoapp makeCall error: \(result.reason.description)")
            return .error(result.reason.description)
        }

        self.call = call
        self.peerId = peerId
        isIncomingCall = false
        stateSubject.send(.connecting)
        AppLog.v("#vs myvideo, peervideo")
        if useVideo {
            call.peerVideoReceiver = _peerVideoStream
        }

        guard await observeMyMediaStatus() else {
            return .error(result.reason.description)
        }

        #if os(iOS)
        callKitService.reportOutgoingCall(call: call, peerId: peerId, hasVideo: useVideo) { [weak self] success in
            if !success {
                self?.endCall(error: true)
            } else {
            }
        }
        #endif
        return .success
    }

    @MainActor
    func verifyCall(message: PushMessage) async -> CallResult {
        let reportFailedCall: () -> Void = {
            #if os(iOS)
            self.callKitService.reportFailedCall { _ in }
            #endif
        }

        guard call == nil else {
            reportFailedCall()
            return .error(CallStartRecord.invalidCallReason)
        }

        let settings = try! PlanetKitVerifyCallSettingBuilder()
            .withResponseOnEnableVideo(response: .pause)
            .withCustomCameraStreamKey(videoStream: _myVideoStream.videoStream)
            .withSetRingToneKey(fileResourceUrl: Bundle.main.url(forResource: "48k-Ring", withExtension: "wav")!)
            .withSetEndToneKey(fileResourceUrl: Bundle.main.url(forResource: "48k-End", withExtension: "wav")!)
            .withSetHoldToneKey(fileResourceUrl: Bundle.main.url(forResource: "48k-Hold", withExtension: "wav")!)
            .withEnableStatisticsKey(enable: true)
            #if os(iOS)
            .withCallKitSettingsKey(setting: PlanetKitCallKitSetting(type: .user, param: nil))
            #endif
            .build()

        let myUserId = PlanetKitUserId(id: userAccount.userId, serviceId: userAccount.serviceId)

        guard let ccParam = PlanetKitCCParam(ccParam: message.param), let _ = ccParam.peerId else {
            AppLog.v("#demoapp invalid ccParam \(message)")
            reportFailedCall()
            return .error(CallStartRecord.invalidCCParamReason)
        }

        let useVideo = ccParam.mediaType.hasVideo
        let result = PlanetKitManager.shared.verifyCall(myUserId: myUserId, ccParam: ccParam, settings: settings, delegate: self)

        guard result.reason == .none, let call = result.call else {
            reportFailedCall()
            return .error(result.reason.description)
        }

        self.call = call
        self.peerId = call.peerUserId?.id ?? "<error>"
        isIncomingCall = true
        stateSubject.send(.connecting)
        AppLog.v("#vs myvideo, peervideo")
        if useVideo {
            call.peerVideoReceiver = _peerVideoStream
        }

        guard await observeMyMediaStatus() else {
            reportFailedCall()
            return .error(CallStartRecord.myMediaStatusErrorReason)
        }

        #if os(iOS)
        return await withUnsafeContinuation { continuation in
            callKitService.reportIncomingCall(call: call, peerId: ccParam.peerId!, hasVideo: ccParam.mediaType.hasVideo) { [weak self] success in
                if !success {
                    self?.endCall(error: true)
                    continuation.resume(returning: .error(CallStartRecord.callKitErrorReason))
                } else {
                    continuation.resume(returning: .success)
                }
            }
        }
        #elseif os(macOS)
        return .success
        #endif
    }

    func acceptCall() {
        guard let call = call else {
            return
        }

        let startMessage: PlanetKitCallStartMessage? = nil
        call.acceptCall(startMessage: startMessage, useResponderPreparation: false, recordOnCloud: false)
    }

    func declineCall() {
        guard let call = call else {
            return
        }

        call.declineCall()
    }

    func endCall(error: Bool = false) {
        guard let call = call else {
            return
        }

        if error {
            call.endCall(errorUserReleaseCode: "")
        } else {
            call.endCall(normalUserReleaseCode: "")
        }
    }

    func muteMyAudio(mute: Bool) {
        guard let call = call else {
            return
        }
        AppLog.v("#demo mute >> \(mute)")
        call.muteMyAudio(mute) { [weak self] success in
            AppLog.v("#demo mute << \(success)")
            if success {
                #if os(iOS)
                self?.callKitService.reportMute(call: call, muted: mute)
                #endif
            }
        }
    }

    func pauseMyVideo(pause: Bool) {
        guard let call = call else {
            return
        }
        if pause {
            AppLog.v("#demo pause >>")
            call.pauseMyVideo { success in
                AppLog.v("#demo pause << \(success)")
            }
        } else {
            AppLog.v("#demo resume >>")
            call.resumeMyVideo { success in
                AppLog.v("#demo resume << \(success)")
            }
        }
    }

    func switchCameraPosition() {
        guard let call = call else {
            return
        }
        #if os(iOS)
        call.camera?.switchPosition()
        #endif
    }

    func hold() {
        guard let call = call else {
            return
        }
        AppLog.v("#demo hold >>")
        call.hold(reason: nil) { [weak self] success in
            if success {
                #if os(iOS)
                self?.callKitService.reportHold(call: call, onHold: true)
                #endif
            }
            AppLog.v("#demo hold << \(success)")
        }
    }

    func unhold() {
        guard let call = call else {
            return
        }
        AppLog.v("#demo unhold >>")
        call.unhold { [weak self] success in
            if success {
                #if os(iOS)
                self?.callKitService.reportHold(call: call, onHold: false)
                #endif
            }
            AppLog.v("#demo unhold << \(success)")
        }
    }
}

extension PlanetCallService {
    @MainActor
    private func observeMyMediaStatus() async -> Bool {
        guard let call = call else {
            return false
        }

        return await withCheckedContinuation { continuation in
            call.myMediaStatus.addHandler(_myMediaStatus) { success in
                AppLog.v("#demo \(#function) addHandler result \(success)")
                if success {
                    self._myMediaStatus.isMuted = call.myMediaStatus.isMyAudioMuted
                    self._myMediaStatus.isVideoPaused = call.myMediaStatus.videoStatus.isPausedOrDisabled
                }
                continuation.resume(returning: success)
            }
        }
    }
}

enum CallEvent {
    case onWaitConnected
    case onConnected
    case onDisconnected(_ reason: String)
    case onVerified(_ startMessage: String?)
    case onFinishedPreparation
    case onPeerMicMuted
    case onPeerMicUnmuted
    case onPeerVideoPaused
    case onPeerVideoResumed
    case onPeerAverageAudioLevel(_ level: Int)
}

extension PlanetCallService: PlanetKitCallDelegate {

    func didWaitConnect(_ call: PlanetKitCall) {
        DispatchQueue.main.async {
            self.subject.send(.onWaitConnected)
        }
    }

    func didConnect(_ call: PlanetKitCall, connected: PlanetKitCallConnectedParam) {
        DispatchQueue.main.async {

            #if os(iOS)
            self.callKitService.reportConnected(call: call)
            #endif

            call.peerAudioDescriptionReceiver = self

            self.stateSubject.send(.connected)
            self.callStartTime = Date()
            self.callEndTime = nil
            self.subject.send(.onConnected)
        }
    }

    func didDisconnect(_ call: PlanetKitCall, disconnected: PlanetKitDisconnectedParam) {
        DispatchQueue.main.async {
            #if os(iOS)
            self.callKitService.reportEndCall(call: call)
            #endif

            AppLog.v("#demoapp Disconnected \(disconnected.reason.description)")
            self.stateSubject.send(.disconnected(reason: disconnected.reason.description))
            self.callEndTime = Date()
            self.subject.send(.onDisconnected(disconnected.reason.description))
            self.call = nil
        }
    }

    func didVerify(_ call: PlanetKitCall, peerStartMessage: PlanetKitCallStartMessage?, peerUseResponderPreparation: Bool) {
        DispatchQueue.main.async {
            self.subject.send(.onVerified(peerStartMessage?.data))
        }
    }

    func didFinishPreparation(_ call: PlanetKitCall) {
        DispatchQueue.main.async {
            self.subject.send(.onFinishedPreparation)
        }
    }

    func peerMicDidMute(_ call: PlanetKitCall) {
        DispatchQueue.main.async {
            self.subject.send(.onPeerMicMuted)
        }
    }

    func peerMicDidUnmute(_ call: PlanetKitCall) {
        DispatchQueue.main.async {
            self.subject.send(.onPeerMicUnmuted)
        }
    }

    func peerVideoDidPause(_ call: PlanetKitCall, reason: PlanetKitVideoPauseReason) {
        DispatchQueue.main.async {
            self.subject.send(.onPeerVideoPaused)
        }
    }

    func peerVideoDidResume(_ call: PlanetKitCall) {
        DispatchQueue.main.async {
            self.subject.send(.onPeerVideoResumed)
        }
    }
}

extension PlanetCallService: PlanetKitPeerAudioDescriptionDelegate {
    func peerAudioDescriptionsDidUpdate(_ descriptions: [PlanetKitPeerAudioDescription], averageVolumeLevel: Int8) {
        DispatchQueue.main.async {
            self.subject.send(.onPeerAverageAudioLevel(Int(averageVolumeLevel)))
        }
    }
}
