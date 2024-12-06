import Foundation
import Combine

class MockPushService: PushService {
    func register(user: UserAccount) throws {
        token = "test_token"
        tokenSubject.send(token!)
    }

    func unregister() {
    }

    var token: String?
    var onPush: AnyPublisher<PushMessage, Never> {
        pushSubject.eraseToAnyPublisher()
    }
    var onToken: AnyPublisher<String, Never> {
        tokenSubject.eraseToAnyPublisher()
    }

    var isPushPaused: Bool = false

    private var tokenSubject = PassthroughSubject<String, Never>()
    private var pushSubject = PassthroughSubject<PushMessage, Never>()

    func testPush() {
        pushSubject.send(PushMessage(caller: "test_caller", param: "test_param"))
    }
}
