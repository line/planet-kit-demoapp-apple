import Foundation

struct AppConstant {

    #if os(iOS)
    /// If you call `UINavigationBar.setAnimationsEnabled(false)`, you can set the `navigationStackAnimationDuration` to 0.
    static let navigationStackAnimationDuration = 0.25
    #elseif os(macOS)
    /// In macOS, there is no `NavigationBar`; instead, an `NSToolbar` is used, which does not support animations.
    static let navigationStackAnimationDuration = 0.0
    #endif
    
    static let maxPeerIdLength = 64
    static let maxRoomIdLength = 20
}
