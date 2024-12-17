import Foundation
import Combine

class MockSettingsService: SettingsService {
    var onPush: AnyPublisher<PushMessage, Never> {
        pushSubject.eraseToAnyPublisher()
    }
    var isPushPaused: Bool = false

    var serviceId: String = "test-serviceId"
    var userAccount: UserAccount? = UserAccount(userId: "test-user", serviceId: "test-serviceId", displayName: "test-name", expirationDate: .now, accessToken: nil)
    var onUserAccountUpdate: AnyPublisher<UserAccount?, Never> {
        accountSubject.eraseToAnyPublisher()
    }

    private var accountSubject = PassthroughSubject<UserAccount?, Never>()
    private var pushSubject = PassthroughSubject<PushMessage, Never>()

    var isRegistrationValid: Bool {
        if let userAccount = userAccount, userAccount.expirationDate > Date() {
            return true
        } else {
            return false
        }
    }

    func registerUser(name: String, userId: String) async -> Result<Bool, RegisterUserError> {
        let now = Date()
        let fifteenMinutes: TimeInterval = 15 * 60
        let dateFifteenMinutesFromNow = now.addingTimeInterval(fifteenMinutes)

        let userAccount = UserAccount(userId: userId, serviceId: self.serviceId, displayName: name, expirationDate: dateFifteenMinutesFromNow, accessToken: nil)
        self.userAccount = userAccount
        accountSubject.send(userAccount)

        return .success(true)
    }

    func getAccessToken() async -> String? {
        return "test-token"
    }

    func reset() {
        userAccount = nil
        accountSubject.send(userAccount)
    }

    func testPush() {
        pushSubject.send(PushMessage(caller: "test", param: "test"))
    }
}
