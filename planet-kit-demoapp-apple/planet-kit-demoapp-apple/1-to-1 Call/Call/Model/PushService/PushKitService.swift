import PushKit
import Combine

class PushKitService: NSObject, PushService {
    enum ServiceError: Error {
        case alreadyRegistered
        case timedOut
    }

    private var pushRegistry: PKPushRegistry?

    var onPush: AnyPublisher<PushMessage, Never> {
        pushSubject.eraseToAnyPublisher()
    }
    var onToken: AnyPublisher<String, Never> {
        tokenSubject.eraseToAnyPublisher()
    }

    var token: String?
    var isPushPaused: Bool = false

    private var tokenSubject = PassthroughSubject<String, Never>()
    private var pushSubject = PassthroughSubject<PushMessage, Never>()

    func register(user: UserAccount) throws {
        guard pushRegistry == nil else {
            throw ServiceError.alreadyRegistered
        }

        setup()
        AppLog.v("#demoapp pushkit register")
    }

    func unregister() {
        pushRegistry = nil
        AppLog.v("#demoapp pushkit unregister")
    }

    private func setup() {
        pushRegistry = PKPushRegistry(queue: .main)
        pushRegistry?.delegate = self
        #if os(iOS)
        pushRegistry?.desiredPushTypes = [.voIP]
        #endif
    }
}

extension PushKitService: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {

        AppLog.v("#demoapp \(#function), \(type.rawValue)")

        #if os(iOS)
        guard type == .voIP else { return }
        #endif

        AppLog.v("#demoapp \(#function) onToken()")

        let token = pushCredentials.token.hexEncodedString()

        self.token = token
        tokenSubject.send(token)
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {

        AppLog.v("#demoapp \(#function), \(type.rawValue)")

        #if os(iOS)
        guard type == .voIP else {
            completion()
            return
        }
        #endif

        AppLog.v("#demoapp \(#function) onPush()")

        let message = payload.dictionaryPayload as NSDictionary as! [String: AnyObject]

        guard let caller = message["app_caller_sid"] as? String, let param = message["cc_param"] as? String else {
            AppLog.v("#demoapp \(#function) failed to parse params")
            return
        }

        let pushMessage = PushMessage(caller: caller, param: param)

        self.pushSubject.send(pushMessage)
        completion()
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    }
}

private extension Data {
    func hexEncodedString(uppercase: Bool = false) -> String {
        let hexAlphabet = (uppercase ? "0123456789ABCDEF" : "0123456789abcdef").unicodeScalars.map { $0 }

        return String(reduce(into: "".unicodeScalars, { (result, value) in
            result.append(hexAlphabet[Int(value / 16)])
            result.append(hexAlphabet[Int(value % 16)])
        }))
    }
}
