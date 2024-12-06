import Foundation
import PlanetKit
import Combine

class PlanetGroupCallService: GroupCallService {

    let myUserId: String
    let myName: String
    let roomId: String
    let videoPauseOnStart: Bool
    let muteOnStart: Bool

    var isConnected = false
    var peers: [any GroupCallPeer] = []
    var connectedAt: Date?

    let settingsService: SettingsService
    private let _myMediaStatus: PlanetMyMediaStatus
    private var peersIndexMap: [String: Int] = [:]
    private let eventSubject = PassthroughSubject<GroupCallEvent, Never>()
    private var conference: PlanetKitConference?
    private let _myVideoStream = PlanetVideoStream()

    var onEvent: AnyPublisher<GroupCallEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    var myMediaStatus: any MyMediaStatusObservable {
        _myMediaStatus
    }

    var myVideoStream: any VideoStream {
        _myVideoStream
    }

    var participantCount: Int {
        peers.count + 1
    }

    required init (roomId: String, videoPauseOnStart: Bool, muteOnStart: Bool, settingsService: SettingsService) {
        AppLog.v("#demo PlanetGroupCallSerice \(roomId) \(videoPauseOnStart) \(muteOnStart)")
        self.roomId = roomId
        self.videoPauseOnStart = videoPauseOnStart
        self.muteOnStart = muteOnStart
        self.settingsService = settingsService
        self._myMediaStatus =  PlanetMyMediaStatus(isVideoPaused: videoPauseOnStart, isMuted: muteOnStart, averageAudioLevel: 0)
        self.myUserId = settingsService.userAccount?.userId ?? "error"
        self.myName = settingsService.userAccount?.displayName ?? "error"
    }

    @MainActor
    func startGroupCall() async -> Result<Void, GroupCallStartFailError> {
        guard settingsService.isRegistrationValid, let userAccount = settingsService.userAccount else {
            AppLog.v("#demo \(#function) user account is not valid")
            return .failure(.userAcountInvalid)
        }

        guard let accessToken = await settingsService.getAccessToken() else {
            AppLog.v("#demo \(#function) failed to get access token")
            return .failure(.userAcountInvalid)
        }

        AppLog.v("#demo \(#function) \(roomId) \(accessToken)")
        let myUserId = PlanetKitUserId(id: userAccount.userId, serviceId: userAccount.serviceId)
        let param = PlanetKitConferenceParam(myUserId: myUserId, roomId: roomId, roomServiceId: userAccount.serviceId, displayName: userAccount.displayName, delegate: self, accessToken: accessToken)

        param.mediaType = .audiovideo
        var settingsBuilder = PlanetKitJoinConferenceSettingBuilder()
            .withCustomCameraStreamKey(videoStream: _myVideoStream.videoStream)

        if let endToneUrl = Bundle.main.url(forResource: "48k-End", withExtension: "wav"), let newSettingsBuilder = try? settingsBuilder.withSetEndToneKey(fileResourceUrl: endToneUrl) {
            settingsBuilder = newSettingsBuilder
        }

        let joinResult = PlanetKitManager.shared.joinConference(param: param, settings: settingsBuilder.build())

        guard let conference = joinResult.conference else {
            AppLog.v("#demo \(#function) join failed. \(joinResult.reason.description)")
            return .failure(.internalError(reason: joinResult.reason.description))
        }

        if muteOnStart {
            conference.muteMyAudio(true) { success in
                AppLog.v("#demo \(#function) muteOnStart muteMyAudio result \(success)")
            }
        }

        if videoPauseOnStart {
            conference.pauseMyVideo { success in
                AppLog.v("#demo \(#function) videoPauseOnStart pauseMyVideo result \(success)")
            }
        }

        let result = await withCheckedContinuation { continuation in
            conference.myMediaStatus.addHandler(_myMediaStatus) { [weak self] success in
                guard let `self` = self else { return }
                AppLog.v("#demo \(#function) addHandler result \(success)")
                if success {
                    self.conference = conference
                    _myMediaStatus.isMuted = conference.myMediaStatus.isMyAudioMuted
                    _myMediaStatus.isVideoPaused = conference.myMediaStatus.videoStatus.isPausedOrDisabled
                }
                continuation.resume(returning: success)
            }
        }

        guard result else {
            AppLog.v("#demo \(#function) addHandler result is false")
            return .failure(.internalError(reason: "handler"))
        }

        AppLog.v("#demo start complete \(joinResult.reason)")
        return .success(())
    }

    func endGroupCall() {
        AppLog.v("\(#function) ")
        conference?.leaveConference()
    }

    func switchCameraPosition() {
        guard let camera = conference?.camera else {
            AppLog.v("")
            return
        }

        #if os(iOS)
        camera.switchPosition()
        #endif
    }

    func pauseMyVideo() {
        guard let conference = conference else {
            return
        }

        conference.pauseMyVideo { success in
            AppLog.v("#demoapp \(#function) result \(success)")
        }
        conference.stopPreview()
    }

    func resumeMyVideo() {
        guard let conference = conference else {
            return
        }

        conference.resumeMyVideo { success in
            AppLog.v("#demoapp \(#function) result \(success)")
        }
        conference.startPreview()
    }

    func muteMyAudio(mute: Bool) {
        guard let conference = conference else {
            return
        }

        conference.muteMyAudio(mute) { success in
            AppLog.v("#demoapp \(#function) result \(success)")
        }
    }
}

extension PlanetGroupCallService: PlanetKitConferenceDelegate {
    func didConnect(_ conference: PlanetKitConference, connected: PlanetKitConferenceConnectedParam) {
        DispatchQueue.main.async {  [weak self] in
            guard let `self` = self else { return }
            AppLog.v("#demo \(#function)")
            connectedAt = .now
            isConnected = true
            eventSubject.send(.didConnect)
        }
    }

    func didDisconnect(_ conference: PlanetKitConference, disconnected: PlanetKitDisconnectedParam) {
        DispatchQueue.main.async {  [weak self] in
            guard let `self` = self else { return }
            AppLog.v("#demo \(#function) \(disconnected.reason)")
            isConnected = false
            eventSubject.send(.didDisconnect(reason: disconnected.reason.description))

            conference.myMediaStatus.removeHandler(_myMediaStatus) { success in
                AppLog.v("#demo \(#function) removeHandler \(success)")
            }
        }
    }

    private func addPeer(peer: PlanetGroupCallPeer) {
        AppLog.v("#demo peer \(#function) \(peer.userId)")

        peersIndexMap[peer.userId] = peers.count
        peers.append(peer)
    }

    private func removePeer(id: String) -> PlanetGroupCallPeer? {
        AppLog.v("#demo peer begin \(#function) \(id) \(peers.count) \(peersIndexMap)")
        guard let index = peersIndexMap[id], index < peers.count else {
            AppLog.v("#demo peer \(#function) \(id) \(peers.count) \(peersIndexMap)")
            return nil
        }

        let removedPeer = peers[index]

        peersIndexMap.removeValue(forKey: id)
        peers.remove(at: index)

        peersIndexMap.forEach { (key, value) in
            if value > index {
                peersIndexMap[key] = value - 1
            }
        }

        AppLog.v("#demo peer end \(#function) \(id) \(peers.count) \(peersIndexMap)")

        return removedPeer as? PlanetGroupCallPeer
    }

    func peerListDidUpdate(_ conference: PlanetKitConference, updated: PlanetKitConferencePeerListUpdateParam) {
        DispatchQueue.main.async {  [weak self] in
            AppLog.v("#demo \(#function) \(String(describing: self?.peers))")
            var addedPeers: [any GroupCallPeer] = []
            var removedPeers: [any GroupCallPeer] = []
            for addedPeer in updated.addedPeers {
                guard let peerControl = conference.createPeerControl(peer: addedPeer) else {
                    AppLog.v("#demo \(#function) failed to create peer control for \(addedPeer.id.id)")
                    continue
                }

                let peer = PlanetGroupCallPeer(control: peerControl, id: addedPeer.id.id, name: addedPeer.displayName ?? "error", isMuted: addedPeer.isMuted)

                self?.addPeer(peer: peer)
                addedPeers.append(peer)
            }

            for removedPeer in updated.removedPeers {
                if let removed = self?.removePeer(id: removedPeer.id.id) {
                    AppLog.v("#demo removed peer for \(removedPeer.id.id)")
                    removedPeers.append(removed)
                }
            }
            self?.eventSubject.send(.peerListDidUpdate(addedPeers: addedPeers, removedPeers: removedPeers))
        }
    }

    func peersVideoDidUpdate(_ conference: PlanetKitConference, updated: PlanetKitConferenceVideoUpdateParam) {
        // use peer control
    }
}
