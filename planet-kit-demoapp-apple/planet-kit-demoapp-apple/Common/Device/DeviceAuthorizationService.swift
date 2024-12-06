import AVFoundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum DeviceAuthorizationType {
    case microphone
    case camera

    var mediaType: AVMediaType {
        switch self {
        case .microphone:
            return .audio
        case .camera:
            return .video
        }
    }
}

protocol DeviceAuthorizationService {
    func authorizationStatus(for type: DeviceAuthorizationType) async -> Bool
    func requestAccess(for: DeviceAuthorizationType) async -> Bool
    func openAppSettings(for: DeviceAuthorizationType)
}

class AppleDeviceAuthorizationService: DeviceAuthorizationService {

    func authorizationStatus(for type: DeviceAuthorizationType) async -> Bool {
        let status = await getAuthorizationStatus(for: type)
        return status == .allow
    }

    func requestAccess(for type: DeviceAuthorizationType) async -> Bool {
        let status = await getAuthorizationStatus(for: type)
        if status == .notDetermined {
            return await withUnsafeContinuation { continuation in
                AVCaptureDevice.requestAccess(for: type.mediaType) { granted in
                    continuation.resume(returning: granted)
                }
            }
        }
        return status == .allow
    }

    func openAppSettings(for type: DeviceAuthorizationType) {
        #if os(iOS)
        guard let setingsURL = URL(string: UIApplication.openSettingsURLString + Bundle.main.bundleIdentifier!) else { return }
        UIApplication.shared.open(setingsURL as URL)

        #elseif os(macOS)
        var preferenceUrl: URL {
            let urlString: String
            switch type {
            case .microphone:
                urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone"
            case .camera:
                urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera"
            }
            return URL(string: urlString)!
        }
        NSWorkspace.shared.open(preferenceUrl)
        #endif
    }
}

extension AppleDeviceAuthorizationService {

    private enum Status {
        case allow
        case reject
        case notDetermined
    }

    private func getAuthorizationStatus(for type: DeviceAuthorizationType) async -> Status {
        return await withUnsafeContinuation { continuation in
            switch AVCaptureDevice.authorizationStatus(for: type.mediaType) {
            case .notDetermined:
                continuation.resume(returning: .notDetermined)
            case .denied, .restricted:
                continuation.resume(returning: .reject)
            case .authorized:
                continuation.resume(returning: .allow)
            @unknown default:
                continuation.resume(returning: .reject)
            }
        }
    }
}

class MockDeviceAuthorizationService: DeviceAuthorizationService {

    func authorizationStatus(for type: DeviceAuthorizationType) async -> Bool {
        return true
    }

    func requestAccess(for: DeviceAuthorizationType) async -> Bool {
        return true
    }

    func openAppSettings(for: DeviceAuthorizationType) {
    }
}
