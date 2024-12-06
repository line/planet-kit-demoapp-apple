import Foundation
import Combine
import PlanetKit

class PlanetGroupCallPeer: GroupCallPeer {
    private enum RegisterStatus {
        case trying, completed, failed
    }

    var id: String {
        userId + created.description
    }

    var name: String

    var videoStream: VideoStream {
        _videoStream
    }

    private let eventSubject = PassthroughSubject<PeerEvent, Never>()
    private let control: PlanetKitPeerControl

    let userId: String
    private var status: RegisterStatus
    // TODO: refactor to CurrentValueSubject?
    private(set) var isVideoEnabled: Bool = false
    private(set) var isConnected: Bool = true
    private(set) var isMuted: Bool
    private(set) var averageAudioLevel = 0
    private let created = Date()

    private let _videoStream = PlanetVideoStream()
    var onEvent: AnyPublisher<PeerEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private var pendingContinuations: [CheckedContinuation<Void, Never>] = []

    private func resumePendingTasks() {
        for continuation in pendingContinuations {
            continuation.resume(returning: ())
        }
        pendingContinuations.removeAll()
    }

    init(control: PlanetKitPeerControl, id: String, name: String, isMuted: Bool) {
        self.control = control
        self.userId = id
        self.isMuted = isMuted
        self.name = name
        if let videoStatus = try? control.peer.videoStatus(subgroupName: nil) {
            self.isVideoEnabled = videoStatus.state == .enabled
        }

        status = .trying
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            let registrationSuccess = await registerControl()
            self.status = registrationSuccess ? .completed : .failed
            if registrationSuccess {
                self.resumePendingTasks()
            }
        }

        AppLog.v("#demo \(id) isVideoEnabled: \(self.isVideoEnabled)")
    }

    deinit {
        control.unregister { [weak self] success in
            AppLog.v("#demo register control \(String(describing: self?.userId)) \(success)")
        }
    }

    private func registerControl() async -> Bool {
        await withCheckedContinuation { continuation in
            control.register(self) { success in
                AppLog.v("#demo register control \(self.userId) \(success)")
                continuation.resume(returning: success)
            }
        }
    }

    func startVideo() async -> Bool {
        AppLog.v("#demo \(#function) \(userId)")
        if status == .trying {
            await withCheckedContinuation { continuation in
                pendingContinuations.append(continuation)
            }
        }

        guard status == .completed else {
            AppLog.v("#demo start video failed: registration not completed")
            return false
        }

        let result = await withCheckedContinuation { continuation in
            control.startVideo(maxResolution: .recommended, delegate: _videoStream) { [weak self] success in
                AppLog.v("#demo start video \(String(describing: self?.userId)) \(success)")
                continuation.resume(returning: success)
            }
        }

        AppLog.v("#demo \(#function) \(userId) result: \(result)")
        return result
    }

    func stopVideo() async -> Bool {
        AppLog.v("#demo \(#function) \(userId)")

        if status == .trying {
            await withCheckedContinuation { continuation in
                pendingContinuations.append(continuation)
            }
        }

        guard status == .completed else {
            AppLog.v("#demo start video failed: registration not completed")
            return false
        }

        let result = await withCheckedContinuation { continuation in
            control.stopVideo { [weak self] success in
                AppLog.v("#demo stop video \(String(describing: self?.userId)) \(success)")
                continuation.resume(returning: success)
            }
        }

        AppLog.v("#demo \(#function) \(userId) result: \(result)")
        return result
    }
}

extension PlanetGroupCallPeer: PlanetKitPeerControlDelegate {
    func didMuteMic(_ peerControl: PlanetKitPeerControl) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            AppLog.v("\(#function)")
            self.isMuted = true
            self.eventSubject.send(.muted(true))
        }
    }

    func didUnmuteMic(_ peerControl: PlanetKitPeerControl) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            AppLog.v("\(#function)")
            self.isMuted = false
            self.eventSubject.send(.muted(false))
        }
    }

    func didDisconnect(_ peerControl: PlanetKitPeerControl) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            AppLog.v("\(#function)")
            self.isConnected = false
            self.eventSubject.send(.disconnected)
        }
    }

    func didUpdateAudioDescription(_ peerControl: PlanetKitPeerControl, description: PlanetKitPeerAudioDescription) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.averageAudioLevel = Int(description.averageVolumeLevel)
            self.eventSubject.send(.averageAudioLevel(Int(description.averageVolumeLevel)))
        }
    }

    func didUpdateVideo(_ peerControl: PlanetKitPeerControl, subgroup: PlanetKitSubgroup, status: PlanetKitVideoStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            AppLog.v("\(#function)")
            self.isVideoEnabled = status.state == .enabled
            self.eventSubject.send(.videoEnabled(status.state == .enabled))
        }
    }
}
