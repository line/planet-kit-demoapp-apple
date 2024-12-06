import Foundation
import Combine

struct PushMessage {
    let caller: String
    let param: String
}

protocol PushService {
    var token: String? { get }
    func register(user: UserAccount) throws
    func unregister()
    var isPushPaused: Bool { get set }
    var onPush: AnyPublisher<PushMessage, Never> { get }
    var onToken: AnyPublisher<String, Never> { get }
}
