import Foundation
import Combine
import PlanetKit

class PlanetSettingsService: SettingsService {
    var userAccount: UserAccount? {
        accountSubject.value
    }

    var onUserAccountUpdate: AnyPublisher<UserAccount?, Never> {
        accountSubject.eraseToAnyPublisher()
    }

    var onPush: AnyPublisher<PushMessage, Never> {
        pushSubject.eraseToAnyPublisher()
    }

    var isPushPaused: Bool {
        set {
            pushService.isPushPaused = newValue
        }
        get {
            pushService.isPushPaused
        }
    }

    private var accountSubject = CurrentValueSubject<UserAccount?, Never>(nil)
    private var pushSubject = PassthroughSubject<PushMessage, Never>()

    private let repository: AppServerRepository = PlanetAppServerRepository()
    private var pushService: PushService

    private var pushCancellable: AnyCancellable?
    private var tokenCancellable: AnyCancellable?
    private var expirationCancellable: AnyCancellable?

    var isRegistrationValid: Bool {
        if let userAccount = userAccount, userAccount.expirationDate > Date() {
            return true
        } else {
            return false
        }
    }

    init() {
        pushService = LongPollingService()
    }

    @MainActor func registerUser(name: String, userId: String) async -> Result<Bool, RegisterUserError> {
        let result = await repository.registerUser(userId: userId, displayName: name)

        switch result {
        case .success(let userAccount):
            let success = await repository.registerDevice(user: userAccount)
            guard success else {
                return .failure(.unknown)
            }
            update(userAccount: userAccount)
            accountSubject.send(userAccount)
            registerPush()
            setUserExpirationTimer()
            return .success(true)

        case .failure(let error):
            AppLog.v("#demoapp failed to register user with \(name) \(userId) \(error)")
            accountSubject.send(nil)
            return .failure(error)
        }
    }

    func getAccessToken() async -> String? {
        guard let userAccount = userAccount else {
            AppLog.v("#demo user account is nil")
            return nil
        }
        return await repository.getAccessToken(user: userAccount)
    }

    func reset() {
        accountSubject.send(nil)
        update(userAccount: nil)
        unregisterPush()
        resetUserExpirationTimer()
    }

    private func unregisterPush() {
        pushCancellable?.cancel()
        tokenCancellable?.cancel()
        pushService.unregister()
    }

    private func registerPush() {
        guard isRegistrationValid, let userAccount = userAccount else {
            AppLog.v("#demoapp push register failed")
            return
        }

        pushCancellable = pushService.onPush
            .sink { [weak self] message in
                self?.pushSubject.send(message)
            }

        tokenCancellable = pushService.onToken
            .sink { token in
                Task { @MainActor [weak self] in
                    guard let `self` = self else { return }
                    guard let userAccount = self.userAccount else { return }
                    let result = await repository.updateNotificationToken(user: userAccount, token: token)
                    AppLog.v("#demoapp updated token \(result) for \(userAccount.userId) using \(token)")
                }
            }

        do {
            try pushService.register(user: userAccount)
            AppLog.v("#demoapp registerPush success")
        } catch {
            AppLog.v("#demoapp registerPush \(error)")
        }
    }

    private func resetUserExpirationTimer() {
        expirationCancellable?.cancel()
        expirationCancellable = nil
    }

    private var remainingExpirationTime: TimeInterval? {
        guard let userAccount = userAccount else {
            return nil
        }
        return Date().distance(to: userAccount.expirationDate)
    }

    private func setUserExpirationTimer() {
        guard let remainingTime = remainingExpirationTime, remainingTime > 0 else {
            return
        }
        AppLog.v("#demoapp remain time: \(remainingTime)")
        expirationCancellable = Timer.publish(every: remainingTime + 0.001, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                if let userAccount = userAccount, !isRegistrationValid {
                    AppLog.v("#demoapp user account expired \(userAccount.userId) \(userAccount.expirationDate)")
                    reset()
                }
            }
    }
}

extension PlanetSettingsService {

    enum AppKeys: String {
        case userAccount
        var key: String { rawValue }
    }

    func loadLastUserAccount() {
        guard let jsonString = UserDefaults.standard.string(forKey: AppKeys.userAccount.key),
              let jsonData = jsonString.data(using: .utf8),
              let userAccount = try? JSONDecoder().decode(UserAccount.self, from: jsonData) else {
            accountSubject.send(nil)
            return
        }

        accountSubject.send(userAccount)
        registerPush()
        setUserExpirationTimer()
    }

    private func update(userAccount: UserAccount?) {
        if let userAccount = userAccount,
           let jsonData = try? JSONEncoder().encode(userAccount) {
            let jsonString = String(data: jsonData, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: AppKeys.userAccount.key)
        } else {
            UserDefaults.standard.removeObject(forKey: AppKeys.userAccount.key)
        }
    }
}
