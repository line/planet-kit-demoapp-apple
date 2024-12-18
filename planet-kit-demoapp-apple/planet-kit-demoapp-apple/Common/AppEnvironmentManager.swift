import PlanetKit
#if os(iOS)
import UIKit
#endif

struct AppEnvironmentManager {
    static func initialize() {
        let settings = PlanetKitInitialSettingBuilder()
            .withSetKitServerKey(serverUrl: PlanetAppServerRepository().serverUrl)
            .build()

        PlanetKitManager.shared.initialize(initialSettings: settings)

        AppLog.v("#demoapp userAgent = \(PlanetKitManager.shared.userAgent)")
        AppLog.v("#demoapp log path = \(PlanetKitManager.shared.basePath)")
    }

    static var appName = {
        if let name = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return name
        }
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }()

    static var appVersion = {
        let baseVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "\(baseVersion).\(buildNumber)"
    }()

    static var sdkVersion: String = {
        PlanetKitManager.shared.version
    }()

    static func onMainViewAppear() {
        #if os(iOS)
        if let orientation = UIWindowScene.firstSceneOrientation {
            PlanetKitDeviceHandler.shared.orientation = orientation
        }
        #endif
    }
}
