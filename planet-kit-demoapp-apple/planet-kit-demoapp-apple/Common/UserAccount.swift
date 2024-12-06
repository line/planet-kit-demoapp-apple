import Foundation

struct UserAccount: Codable {
    let userId: String
    let serviceId: String
    let displayName: String?
    let expirationDate: Date
    let accessToken: String?
}

extension UserAccount {
    static let testAccount = UserAccount(userId: "test", serviceId: "test", displayName: "test", expirationDate: .distantFuture, accessToken: nil)
}
