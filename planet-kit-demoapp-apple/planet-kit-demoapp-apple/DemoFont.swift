import SwiftUI

struct DemoFont {
    static let buttons: Font = .system(size: 17).weight(.bold)
    static let `default`: Font = .system(size: 15)
    static let small: Font = .system(size: 13)

    static let normalButton: Font = {
        #if os(iOS)
        .system(size: 30)
        #elseif os(macOS)
        .system(size: 24)
        #endif
    }()

    static let roundButton: Font = {
        #if os(iOS)
        .system(size: 24)
        #elseif os(macOS)
        .system(size: 24)
        #endif
    }()
}
