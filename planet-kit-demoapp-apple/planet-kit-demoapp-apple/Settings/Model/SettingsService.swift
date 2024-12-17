import Foundation
import Combine

protocol SettingsService {
    var userAccount: UserAccount? { get }
    var onUserAccountUpdate: AnyPublisher<UserAccount?, Never> { get }
    var onPush: AnyPublisher<PushMessage, Never> { get }
    var isPushPaused: Bool { get set }

    var isRegistrationValid: Bool { get }
    @MainActor func registerUser(name: String, userId: String) async -> Result<Bool, RegisterUserError>
    @MainActor func getAccessToken() async -> String?
    func reset()
}
