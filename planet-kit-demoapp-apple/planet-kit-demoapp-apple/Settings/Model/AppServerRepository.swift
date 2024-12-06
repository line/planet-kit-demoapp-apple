import Foundation

enum RegisterUserError: Error {
    case userIdExist
    case unknown
}

enum NotificationError: Error {
    case retry
    case unknown
}

protocol AppServerRepository {
    var serviceId: String { get }
    var serverUrl: String { get }

    func registerUser(userId: String, displayName: String) async -> Result<UserAccount, RegisterUserError>
    func registerDevice(user: UserAccount) async -> Bool
    func updateNotificationToken(user: UserAccount, token: String) async -> Bool
    func getNotification(user: UserAccount) async -> Result<PushMessage, NotificationError>
    func getAccessToken(user: UserAccount) async -> String?
}
