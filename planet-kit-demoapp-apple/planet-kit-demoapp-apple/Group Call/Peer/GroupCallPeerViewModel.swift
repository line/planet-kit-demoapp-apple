import Foundation
import Combine

class GroupCallPeerViewModel: ObservableObject {
    private static let speakingAudioLevelThreshHold = 5

    @Published var isConnected: Bool
    @Published var isMuted: Bool
    @Published var isSpeaking: Bool
    @Published var isVideoEnabled: Bool

    private let errorSubject = PassthroughSubject<String, Never>()
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    let userId: String
    let name: String
    let peer: any GroupCallPeer
    private var cancellables = Set<AnyCancellable>()

    init(peer: any GroupCallPeer) {
        userId = peer.userId
        name = peer.name
        isConnected = peer.isConnected
        isMuted = peer.isMuted
        isSpeaking = peer.averageAudioLevel > GroupCallPeerViewModel.speakingAudioLevelThreshHold ? true : false
        isVideoEnabled = peer.isVideoEnabled
        self.peer = peer
        bindService()
    }

    private func bindService() {
        peer.onEvent
            .sink { [weak self] event in
                switch event {
                case .disconnected:
                    self?.isConnected = false
                case .muted(let mute):
                    self?.isMuted = mute
                case .averageAudioLevel(let level):
                    self?.isSpeaking = level > GroupCallPeerViewModel.speakingAudioLevelThreshHold ? true : false
                case .videoEnabled(let enabled):
                    self?.isVideoEnabled = enabled
                }
            }
            .store(in: &cancellables)
    }

    func startVideo() {
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            if await peer.startVideo() == false {
                errorSubject.send("video start failed")
            }
        }
    }

    func stopVideo() {
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            if await peer.stopVideo() == false {
                errorSubject.send("video stop failed")
            }
        }
    }
}
