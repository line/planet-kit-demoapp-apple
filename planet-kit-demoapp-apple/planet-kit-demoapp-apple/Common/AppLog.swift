import PlanetKit

struct AppLog {
    static func v(_ message: @autoclosure () -> String) {
        let msg = message()
        NSLog(msg)
    }

    static func v(_ error: @autoclosure () -> Error) {
        let msg = "\(error())"
        NSLog(msg)
    }
}
