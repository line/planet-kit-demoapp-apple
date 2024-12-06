import CallKit
import AVFAudio
import PlanetKit

#if os(macOS)
class CallKitService {
    /// macOS does not support CallKit.
}
#endif

#if os(iOS)
import UIKit

class CallKitService: NSObject {

    private var provider: CXProvider?
    private var callController: CXCallController?
    private var syncLock = NSLock()

    private var calls: [ UUID: PlanetKitCall] = [:]
    private var conferences: [ UUID: PlanetKitConference] = [:]

    var useResponderPreparation = false
    var startMessage: PlanetKitCallStartMessage?

    private var requestedActions: Set<UUID> = []
    private var isAudioSessionActivated: Bool = false

    func register() throws {
        syncLock.lock()
        setup()
        syncLock.unlock()
    }

    private func setup() {
        AppLog.v("#demoapp CallKitService \(#function)")

        guard provider == nil, callController == nil else {
            AppLog.v("#demoapp CallKitService is already set up")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        } catch {
            AppLog.v("#demoapp failed to set audio sesion category to playAndRecord")
        }

        provider = CXProvider(configuration: defaultProviderConfiguration())
        provider?.setDelegate(self, queue: .main)
        callController = CXCallController(queue: .main)
        callController?.callObserver.setDelegate(self, queue: .main)
    }

    private func providerConfiguration(with supportVideo: Bool) -> CXProviderConfiguration {
        let configuration = defaultProviderConfiguration()
        configuration.supportsVideo = supportVideo
        return configuration
    }

    private func defaultProviderConfiguration() -> CXProviderConfiguration {
        let appName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? ""
        let configuration: CXProviderConfiguration = {
            if #available(iOS 14.0, macOS 11.0, *) {
                return CXProviderConfiguration()
            } else {
                return CXProviderConfiguration(localizedName: appName)
            }
        }()

        let handleTypes: Set<CXHandle.HandleType> = [.generic]
        configuration.ringtoneSound = nil
        configuration.iconTemplateImageData = UIImage(named: "callkit_icon")?.pngData()
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportsVideo = false
        configuration.supportedHandleTypes = handleTypes
        configuration.includesCallsInRecents = true

        return configuration
    }

    private func callUpdate(_ peerId: String, hasVideo: Bool) -> CXCallUpdate {
        let identifier = peerId
        let update = CXCallUpdate()

        update.remoteHandle = CXHandle(type: .generic, value: identifier)
        update.localizedCallerName = identifier
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false
        update.supportsHolding = true
        update.hasVideo = hasVideo

        return update
    }

    func reportIncomingCall(call: PlanetKitCall,
                            peerId: String,
                            hasVideo: Bool,
                            completion: ((Bool) -> Void)? = nil) {
        guard let provider = provider else {
            AppLog.v("#demoapp reportIncomingCall provider instance not available")
            return
        }

        provider.reportNewIncomingCall(with: call.uuid, update: callUpdate(peerId, hasVideo: hasVideo)) {
            if let error = $0 {
                AppLog.v("#demoapp reportNewIncomingCall Error:\(error)")
                completion?(false)
            } else {
                self.calls[call.uuid] = call
                completion?(true)
            }
        }
    }

    /// the purpose of this function is to avoid VoIP push drop when a VoIP push is not matched with a CallKit API
    func reportFailedCall(completion: @escaping (Bool) -> Void) {
        guard let provider = provider else {
            AppLog.v("#demoapp reportIncomingCall provider instance not available")
            return
        }

        let uuid = UUID()

        provider.reportNewIncomingCall(with: uuid, update: callUpdate("", hasVideo: false)) {
            if let error = $0 {
                AppLog.v("#demoapp reportNewIncomingCall Error:\(error)")
                completion(false)
            } else {
                self.reportEndCall(uuid: uuid)
                completion(true)
            }
        }
    }

    private func reportEndCall(uuid: UUID) {
        guard let provider = provider else {
            AppLog.v("#demoapp reportEndCall provider instance not available")
            return
        }

        guard let callController = callController else {
            AppLog.v("#demoapp reportEndCall callController instance not available")
            return
        }

        provider.reportCall(with: uuid, endedAt: nil, reason: .remoteEnded)
        let transaction = CXTransaction(action: CXEndCallAction(call: uuid))

        callController.request(transaction) {
            if let error = $0 {
                AppLog.v("reportEndCall Error : \(error)")
            }
        }

        calls.removeValue(forKey: uuid)
        conferences.removeValue(forKey: uuid)
    }

    func reportEndCall(call: PlanetKitCall) {
        reportEndCall(uuid: call.uuid)
    }

    func reportEndCall(conference: PlanetKitConference) {
        reportEndCall(uuid: conference.uuid)
    }

    func reportConnected(call: PlanetKitCall) {
        AppLog.v("#demoapp report connected \(call.uuid)")
        switch call.direction {
        case .incoming:
            provider?.pendingCallActions(of: CXAnswerCallAction.self, withCall: call.uuid).forEach {
                $0.fulfill()
            }
        case .outgoing:
            provider?.reportOutgoingCall(with: call.uuid, connectedAt: nil)
        case .unknown:
            AppLog.v("#demoapp use of callkit with unknown call direction")
        }
    }

    func reportConnected(conference: PlanetKitConference) {
        AppLog.v("#demoapp report connected \(conference.uuid)")
        provider?.reportOutgoingCall(with: conference.uuid, connectedAt: nil)
    }

    func reportOutgoingCall(call: PlanetKitCall, peerId: String, hasVideo: Bool, completion: ((Bool) -> Void)? = nil) {
        reportOutgoingCall(uuid: call.uuid, peerId: peerId, hasVideo: hasVideo) { success in
            if success {
                self.calls[call.uuid] = call
            }
            completion?(success)
        }
    }

    func reportOutgoingCall(conference: PlanetKitConference, roomId: String, hasVideo: Bool, completion: ((Bool) -> Void)? = nil) {
        reportOutgoingCall(uuid: conference.uuid, peerId: roomId, hasVideo: hasVideo) { success in
            if success {
                self.conferences[conference.uuid] = conference
            }
            completion?(success)
        }
    }

    private func reportOutgoingCall(uuid: UUID, peerId: String, hasVideo: Bool, completion: @escaping ((Bool) -> Void)) {
        AppLog.v("#demoapp \(#function) uuid \(uuid) peerId \(peerId) hasVideo \(hasVideo)")

        guard let provider = provider else {
            AppLog.v("#demoapp \(#function) provider instance not available")
            completion(false)
            return
        }

        guard let callController = callController else {
            AppLog.v("#demoapp \(#function) callController instance not available")
            completion(false)
            return
        }

        provider.configuration = providerConfiguration(with: hasVideo)
        let handle = CXHandle(type: .generic, value: peerId)
        let update = callUpdate(peerId, hasVideo: hasVideo)
        let action = CXStartCallAction(call: uuid, handle: handle)
        action.isVideo = hasVideo

        AppLog.v("#demoapp \(#function) \(update.supportsHolding)")

        callController.requestTransaction(with: action) { error in
            if let error = error {
                AppLog.v("#demoapp \(#function) failed with error: \(error)")
                completion(false)
            } else {
                provider.reportCall(with: uuid, updated: update)
                AppLog.v("#demoapp \(#function) call")
                completion(true)
            }
        }
    }

    func reportMute(call: PlanetKitCall, muted: Bool) {
        reportMute(uuid: call.uuid, muted: muted)
    }

    func reportMute(conference: PlanetKitConference, muted: Bool) {
        reportMute(uuid: conference.uuid, muted: muted)
    }

    private func reportMute(uuid: UUID, muted: Bool) {
        AppLog.v("#demoapp \(#function) \(uuid) \(muted)")

        guard let callController = callController else {
            AppLog.v("#demoapp \(#function) callController instance not available")
            return
        }

        let action = CXSetMutedCallAction(call: uuid, muted: muted)
        callController.requestTransaction(with: action) { error in
            guard error == nil else {
                AppLog.v("#demoapp \(#function) error \(String(describing: error))")
                return
            }
            self.requestedActions.insert(action.uuid)
        }
    }

    func reportHold(call: PlanetKitCall, onHold: Bool) {
        reportHold(uuid: call.uuid, onHold: onHold)
    }

    func reportHold(conference: PlanetKitConference, onHold: Bool) {
        reportHold(uuid: conference.uuid, onHold: onHold)
    }

    private func reportHold(uuid: UUID, onHold: Bool) {
        AppLog.v("#demoapp \(#function) \(uuid) \(onHold)")

        guard let callController = callController else {
            AppLog.v("#demoapp \(#function) callController instance not available")
            return
        }

        AppLog.v("#demoapp \(#function) \(uuid) \(onHold)")
        let action = CXSetHeldCallAction(call: uuid, onHold: onHold)
        callController.requestTransaction(with: action) { error in
            guard error == nil else {
                AppLog.v("#demoapp \(#function) error \(String(describing: error))")
                return
            }
            self.requestedActions.insert(action.uuid)

            if !onHold, !self.isAudioSessionActivated {
                if let call = self.calls[uuid] {
                    call.notifyCallKitAudioActivation()
                } else if let conference = self.conferences[uuid] {
                    conference.notifyCallKitAudioActivation()
                }
            }
        }
    }
}

extension CallKitService {

    private func performEndCallAction(call: PlanetKitCall) {
        switch call.state {
        case .connected, .waitAnswer:
            call.endCall()
        case .verified:
            call.declineCall()
        case .trying:
            if call.direction == .incoming {
                call.declineCall()
            } else {
                call.endCall()
            }
        case .disconnected:
            AppLog.v("#demoapp call is already disconnected")
        default:
            AppLog.v("#demoapp invalid state \(String(describing: call.state)) ")
        }
    }

    private func performEndCallAction(conference: PlanetKitConference) {
        conference.leaveConference()
    }

    private func performSetMutedCallAction(call: PlanetKitCall, action: CXSetMutedCallAction) {
        call.muteMyAudio(action.isMuted) { success in
            guard success else {
                action.fail()
                return
            }
            action.fulfill()
        }
    }

    private func performSetMutedCallAction(conference: PlanetKitConference, action: CXSetMutedCallAction) {
        conference.muteMyAudio(action.isMuted) { success in
            guard success else {
                action.fail()
                return
            }
            action.fulfill()
        }
    }

    private func performSetHeldCallAction(call: PlanetKitCall, action: CXSetHeldCallAction) {
        if action.isOnHold {
            call.hold(reason: nil) { success in
                guard success else {
                    action.fail()
                    return
                }
                action.fulfill()
            }
        } else {
            call.unhold { success in
                guard success else {
                    action.fail()
                    return
                }
                if !self.isAudioSessionActivated {
                    call.notifyCallKitAudioActivation()
                }
                action.fulfill()
            }
        }
    }

    private func performSetHeldCallAction(conference: PlanetKitConference, action: CXSetHeldCallAction) {
        if action.isOnHold {
            conference.hold(reason: nil) { success in
                guard success else {
                    action.fail()
                    return
                }
                action.fulfill()
            }
        } else {
            conference.unhold { success in
                guard success else {
                    action.fail()
                    return
                }
                if !self.isAudioSessionActivated {
                    conference.notifyCallKitAudioActivation()
                }
                action.fulfill()
            }
        }
    }
}

extension CallKitService: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
    }

    func provider(_ provider: CXProvider, execute transaction: CXTransaction) -> Bool {
        return false
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = calls[action.callUUID] else {
            action.fail()
            return
        }

        /// We can consider giving the user a choice of preparation.
        /// If we find CallKit allow to customize the button or views, we'll reconsider.
        ///
        call.acceptCall(startMessage: startMessage, useResponderPreparation: useResponderPreparation, recordOnCloud: false)
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        if let call = calls[action.callUUID] {
            performEndCallAction(call: call)
        } else if let conference = conferences[action.callUUID] {
            performEndCallAction(conference: conference)
        } else {
            action.fail()
            return
        }

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard requestedActions.contains(action.uuid) == false else {
            requestedActions.remove(action.uuid)
            action.fulfill()
            return
        }

        if let call = calls[action.callUUID] {
            performSetMutedCallAction(call: call, action: action)
        } else if let conference = conferences[action.callUUID] {
            performSetMutedCallAction(conference: conference, action: action)
        } else {
            action.fail()
        }
    }

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard requestedActions.contains(action.uuid) == false else {
            requestedActions.remove(action.uuid)
            action.fulfill()
            return
        }

        if let call = calls[action.callUUID] {
            performSetHeldCallAction(call: call, action: action)
        } else if let conference = conferences[action.callUUID] {
            performSetHeldCallAction(conference: conference, action: action)
        } else {
            action.fail()
        }
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        isAudioSessionActivated = true
        for (_, call) in calls {
            call.notifyCallKitAudioActivation()
        }

        for (_, conference) in conferences {
            conference.notifyCallKitAudioActivation()
        }
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        isAudioSessionActivated = false
    }
}

extension CallKitService: CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
    }
}
#endif
