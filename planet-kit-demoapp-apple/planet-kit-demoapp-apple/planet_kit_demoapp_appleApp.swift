import SwiftUI

@main
struct PlanetKitDemoappAppleApp: App {

    let settingsService = PlanetSettingsService()
    #if os(macOS)
    let deviceEnvironmentManager = DeviceEnvironmentManager(audioDeviceService: PlanetAudioDeviceService(), videoDeviceService: PlanetVideoDeviceService())
    #endif

    init() {
        AppEnvironmentManager.initialize()
        settingsService.loadLastUserAccount()
    }

    var body: some Scene {
        WindowGroup {
            MainView(settingsService: settingsService, deviceAuthService: AppleDeviceAuthorizationService())
            #if os(macOS)
            .frame(minWidth: 640, idealWidth: 640, minHeight: 560, idealHeight: 560)
            .environmentObject(deviceEnvironmentManager)
            #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        .commands {
        SidebarCommands()
        }
        #endif
    }

    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
}

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
    }
}
#elseif os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

// MARK: - APNS
extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        assertionFailure("Use VoIP push token instead of APNS token")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        assertionFailure("#demoapp apns registration failed: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable: Any]) {
        assertionFailure("#demoapp push notification received: \(data)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        assertionFailure("#demoapp push notification received")
    }
}
#endif
