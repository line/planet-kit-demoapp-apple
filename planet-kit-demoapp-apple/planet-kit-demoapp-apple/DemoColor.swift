import SwiftUI

struct DemoColor {

    // Main view
    static let activeGreen: Color = { // ThemeColor/Primary
        Color(red: 0.02, green: 0.78, blue: 0.33)
    }()

    static let disableGray: Color = { // Disabled-Gray
        Color(red: 0.89, green: 0.89, blue: 0.89)
    }()

    static let buttonText: Color = { // ThemeColor/OnSurface
        .white
    }()

    static let errorMessage: Color = { // Error message
        Color(red: 0.9, green: 0.09, blue: 0.18)
    }()

    // NOTE: ColorScheme hang problem.
    //  A potential issue with ColorScheme and SwiftUI has been discovered on macOS.
    //  It will be revisited once the bug is resolved on macOS.
    //
    //    static func footerInfo(_ colorScheme: ColorScheme) -> Color { // Footer info
    //        colorScheme.isDark ? .white: .black
    //    }
    //
    //    static func background(_ colorScheme: ColorScheme) -> Color { // Bg
    //        colorScheme.isDark ? Color(red: 0.15, green: 0.15, blue: 0.15): .white
    //    }
    //
    //    // Setting view
    //    static func inputItemTitle(_ colorScheme: ColorScheme) -> Color { // Top menu
    //        colorScheme.isDark ? .white: .black
    //    }
    //
    //    static func title(_ colorScheme: ColorScheme) -> Color { // Title
    //        colorScheme.isDark ? Color(red: 0.88, green: 0.88, blue: 0.88): .black
    //    }

    static let required: Color = { // Required
        Color(red: 1, green: 0.2, blue: 0.29)
    }()

    static let gray300: Color = { // Gray/300
        Color(red: 0.87, green: 0.87, blue: 0.87)
    }()

    static let gray350: Color = { // Gray/350
        Color(red: 0.78, green: 0.78, blue: 0.78)
    }()

    static let gray500: Color = { // Gray/500
        Color(red: 0.58, green: 0.58, blue: 0.58)
    }()

    // Incoming Call view
    static let buttonIconOnIncomingCall: Color = {
        Color(red: 0.25, green: 0.25, blue: 0.25)
    }()

    static let backgroundOnIncomingCall: Color = {
        Color(red: 0.25, green: 0.25, blue: 0.25)
    }()

    static let shadowOnIncomingCall: Color = {
        .black
    }()

    // 1:1 Call view
    static let backgroundOnCall: Color = {
        .black
    }()

    static let toolbarBackgroundOnCall: Color = {
        Color(red: 0.07, green: 0.07, blue: 0.07)
    }()

    static let textOnCall: Color = {
        .white
    }()

    static let iconOnCall: Color = {
        .white
    }()

    static let videoOffDeep: Color = {
        Color(red: 0.20, green: 0.20, blue: 0.20)
    }()

    static let backgroundDark: Color = {
        Color(red: 0.35, green: 0.35, blue: 0.35)
    }()

    static let buttonTransparentBackground: Color = {
        Color(red: 0, green: 0, blue: 0, opacity: 0.25)
    }()

    // Group Call view
    static let backgroundOnGroupCall: Color = {
        .black
    }()

    // Etc
    static let hintGuide: Color = {
        Color(red: 0.58, green: 0.58, blue: 0.58)
    }()

    static let lightPurple: Color = {
        Color(red: 0.875, green: 0.878, blue: 0.984)
    }()
}

private extension ColorScheme {
    var isDark: Bool { self == .dark }
}

// NOTE: ColorScheme hang problem.
//  This is a color value declared in the Asset.
//  We will use this color until the ColorScheme bug is resolved.
//
extension Color {
    static var footerInfo: Color {
        Color("footerInfo")
    }
    static var background: Color {
        Color("background")
    }
    static var inputItemTitle: Color {
        Color("inputItemTitle")
    }
    static var title: Color {
        Color("title")
    }
}
