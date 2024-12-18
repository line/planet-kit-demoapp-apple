import SwiftUI
import Foundation

struct BackNavigationBarItem: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .foregroundColor(.primary)
        }
    }
}

struct UseCaseButton: View {
    let action: () -> Void
    let title: String
    let active: Bool

    var style: some ButtonStyle {
        FilledButtonStyle(title: title, active: true, width: 233, height: 56)
    }

    var style2: some ButtonStyle {
        FilledButtonStyle(title: title, active: true, width: 233, height: 56)
    }
    var body: some View {
        if active {
            Button(action: action, label: {})
                .buttonStyle(FilledButtonStyle(title: title, active: true, width: 233, height: 56))
        } else {
            Button(action: action, label: {})
                .buttonStyle(OutlinedButtonStyle(title: title, active: false, width: 233, height: 56))
                .disabled(true)
        }
    }
}

struct ProfileNoImage: View {
    let size: CGFloat

    var body: some View {
        VStack {
            Image(systemName: "person")
                .font(.system(size: size-30))
                .symbolVariant(.fill.circle)
                .foregroundStyle(.white, .secondary, DemoColor.lightPurple)
        }
        .frame(width: size, height: size)
        .background(DemoColor.lightPurple)
        .cornerRadius(size/2)
    }
}

struct SettingsImage: View {
    let size: CGFloat
    let redDot: Bool

    var body: some View {
        ZStack {
            Image(systemName: "gearshape")
                .font(.system(size: size))
                .foregroundStyle(.primary)

            if redDot {
                Image(systemName: "circle")
                    .font(.system(size: size*0.3))
                    .symbolVariant(.fill)
                    .foregroundStyle(.red)
                    .position(x: size, y: size*0.15)
            }
        }
        .frame(width: size, height: size)
    }
}
