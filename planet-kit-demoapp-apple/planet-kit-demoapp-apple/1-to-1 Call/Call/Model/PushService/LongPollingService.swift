import Foundation
import Combine
#if os(iOS)
import UIKit
#endif

class LongPollingService: NSObject, PushService {
    var onPush: AnyPublisher<PushMessage, Never> {
        pushSubject.eraseToAnyPublisher()
    }
    var onToken: AnyPublisher<String, Never> {
        tokenSubject.eraseToAnyPublisher()
    }

    var token: String?
    var isPushPaused: Bool = false {
        didSet {
            if isPushPaused {
                stopPollingNotification()
            } else {
                if user != nil {
                    startPollingNotification()
                } else {
                    AppLog.v("#demoapp user is nil: cannot start polling")
                }
            }
        }
    }

    private let repository: AppServerRepository = PlanetAppServerRepository()
    private var pollingTask: Task<Void, Never>?

    private var user: UserAccount?
    private var tokenSubject = PassthroughSubject<String, Never>()
    private var pushSubject = PassthroughSubject<PushMessage, Never>()

    #if os(iOS)
    private var foregroundCancellable: AnyCancellable?
    private var backgroundCancellable: AnyCancellable?
    #endif

    func register(user: UserAccount) throws {
        self.user = user
        tokenSubject.send("lp")
        startPollingNotification()

        #if os(iOS)
        foregroundCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                AppLog.v("#demoapp didBecomeActive")
                self?.startPollingNotification()
            }
        backgroundCancellable = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                AppLog.v("#demoapp didEnterBackground")
                self?.stopPollingNotification()
            }
        #endif

        AppLog.v("#demoapp long-polling register")
    }

    func unregister() {
        user = nil
        stopPollingNotification()

        #if os(iOS)
        foregroundCancellable?.cancel()
        backgroundCancellable?.cancel()
        #endif

        AppLog.v("#demoapp long-polling unregister")
    }

    deinit {
        #if os(iOS)
        foregroundCancellable?.cancel()
        backgroundCancellable?.cancel()
        #endif
    }
}

extension LongPollingService {
    private func startPollingNotification() {
        guard pollingTask == nil else {
            AppLog.v("#demoapp #polling already running")
            return
        }
        guard !isPushPaused else {
            AppLog.v("#demoapp #polling paused")
            return
        }
        pollingTask = Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            guard let user = user else { return }

            while !self.isPushPaused && !Task.isCancelled {
                AppLog.v("#demoapp getNotification peerId: \(user)")
                let result = await repository.getNotification(user: user)
                AppLog.v("#demoapp getNotification code: \(result)")

                switch result {
                case .success(let message):
                    pushSubject.send(message)
                case .failure(let error):
                    if error != .retry {
                        do {
                            try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
                        } catch {
                            AppLog.v("#demoapp sleep error \(error)")
                        }
                    }
                }
            }
        }
    }

    private func stopPollingNotification() {
        pollingTask?.cancel()
        pollingTask = nil
        AppLog.v("#demoapp #polling stop - \(user?.userId ?? "")")
    }
}
