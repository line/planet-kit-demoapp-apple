import SwiftUI
import Combine

struct CameraSwitchButton: View {
    let action: () -> Void
    let iconColor: Color

    init(action: @escaping () -> Void, iconColor: Color = .white) {
        self.action = action
        self.iconColor = iconColor
    }

    var body: some View {
        Button(action: action, label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .font(DemoFont.normalButton)
                .foregroundColor(iconColor)
                .frame(width: 50, height: 50)
                .contentShape(.circle)
        })
        .buttonStyle(.borderless)
    }
}

struct AcceptButton: View {
    let action: () -> Void
    let iconColor: Color

    init(action: @escaping () -> Void, iconColor: Color = .white) {
        self.action = action
        self.iconColor = iconColor
    }

    var body: some View {
        Button(action: action, label: {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "phone")
                    .font(.system(size: 60))
                    .symbolVariant(.fill.circle)
                    .foregroundStyle(iconColor, .secondary, .green)
            }
            .contentShape(.circle)
        })
        .buttonStyle(.plain)
    }
}

struct DeclineButton: View {
    let action: () -> Void
    let iconColor: Color

    init(action: @escaping () -> Void, iconColor: Color = .white) {
        self.action = action
        self.iconColor = iconColor
    }

    var body: some View {
        Button(action: action, label: {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "phone.down")
                    .font(.system(size: 60))
                    .symbolVariant(.fill.circle)
                    .foregroundStyle(iconColor, .secondary, .red)
            }
            .contentShape(.circle)
        })
        .buttonStyle(.plain)
    }
}

struct DisconnectCircleButton: View {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action, label: {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "x")
                    .font(.system(size: 60))
                    .symbolVariant(.fill.circle)
                    .foregroundStyle(.white, .secondary, .red)
            }
            .contentShape(.circle)
        })
        .buttonStyle(.plain)
    }
}

struct DisconnectRoundButton: View {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action, label: {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "phone.down")
                    .font(.system(size: 24))
                    .symbolVariant(.fill)
                    .foregroundStyle(.white, .clear, .clear)
            }
            .frame(width: 100, height: 40, alignment: .center)
            .background(.red)
            .contentShape(.capsule)
            .cornerRadius(20)
        })
        .buttonStyle(.plain)
    }
}

struct DevicePickerButton: View {
    enum Style {
        case normal
        case round
    }

    let action: () -> Void
    let style: Style

    init(action: @escaping () -> Void, style: Style) {
        self.action = action
        self.style = style
    }

    var body: some View {
        if style == .round {
            Button(action: action, label: {
                Image(systemName: "chevron.up")
                    .font(DemoFont.roundButton)
                    .symbolVariant(.fill.circle)
                    .scaledToFit()
                    .foregroundStyle(.white, .white, .tertiary)
            })
            .frame(width: 30, height: 30)
            .buttonStyle(.plain)
            .contentShape(.circle)
        } else {
            Button(action: action, label: {
                Image(systemName: "chevron.up")
                    .font(DemoFont.normalButton)
                    .symbolVariant(.fill.circle)
                    .scaledToFit()
                    .foregroundStyle(DemoColor.iconOnCall, .secondary, .tertiary)
            })
            .frame(width: 30, height: 30)
            .buttonStyle(.plain)
        }
    }
}

struct FullscreenClearButton: View {
    let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    var body: some View {
        Button(action: action, label: {
            Color.clear
                .contentShape(.rect)
        })
        .buttonStyle(.plain)
        .edgesIgnoringSafeArea(.all)
    }
}

struct DeviceItemButton: View {
    let action: () -> Void
    let title: String
    let active: Bool
    let disabled: Bool

    var body: some View {
        if active {
            Button(action: action, label: {})
                .buttonStyle(Selected(title: title, height: 20))
                .buttonStyle(.plain)
                .disabled(disabled)
        } else {
            Button(action: action, label: {})
                .buttonStyle(Unselected(title: title, height: 20))
                .buttonStyle(.plain)
                .disabled(disabled)
        }
    }

    struct Selected: ButtonStyle {
        let title: String
        let height: CGFloat?

        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(DemoColor.activeGreen)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
            .frame(height: height, alignment: .center)
        }
    }

    struct Unselected: ButtonStyle {
        let title: String
        let height: CGFloat?

        func makeBody(configuration: Configuration) -> some View {
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 17))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color("title"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
            }
            .frame(height: height, alignment: .center)
        }
    }
}

struct ConnectingDotsView: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<4) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.green)
                    .opacity(animate ? 0.0 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: false)
                            .delay(Double(index) * 0.2),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        Spacer()

        VStack {
            DevicePickerButton(action: {}, style: .round)
            DevicePickerButton(action: {}, style: .normal)
        }
        VStack {
            DeviceItemButton(action: {}, title: "MacBook Pro", active: false, disabled: false)
                .border(.green)
            DeviceItemButton(action: {}, title: "MacBook Pro", active: true, disabled: true)
                .border(.green)
        }
    }
    .background(DemoColor.backgroundDark)
}
