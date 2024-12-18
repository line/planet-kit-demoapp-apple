import SwiftUI

struct MuteButtonView: View {

    enum Style {
        case normal
        case round
    }

    @Binding var isMuted: Bool
    private let action: () -> Void
    private let style: Style

    init(isMuted: Binding<Bool>, action: @escaping () -> Void, style: Style = .normal) {
        _isMuted = isMuted
        self.action = action
        self.style = style
    }

    var body: some View {
        Button(action: action, label: {
            switch style {
            case .normal:
                if isMuted {
                    Image(systemName: "mic")
                        .font(DemoFont.normalButton)
                        .symbolVariant(.slash)
                        .foregroundStyle(.red, .white, .clear)
                        .frame(width: 50, height: 50)
                        .contentShape(.circle)
                } else {
                    Image(systemName: "mic")
                        .font(DemoFont.normalButton)
                        .symbolVariant(.none)
                        .foregroundStyle(.white, .secondary, .tertiary)
                        .frame(width: 50, height: 50)
                        .contentShape(.circle)
                }
            case .round:
                if isMuted {
                    Circle()
                        .background(.clear)
                        .foregroundColor(DemoColor.buttonTransparentBackground)
                        .frame(width: 50, height: 50)
                        .contentShape(.circle)
                        .overlay {
                            Image(systemName: "mic")
                                .font(DemoFont.roundButton)
                                .symbolVariant(.slash)
                                .foregroundStyle(.red, .white, .clear)
                        }
                } else {
                    Circle()
                        .background(.clear)
                        .foregroundColor(DemoColor.buttonTransparentBackground)
                        .frame(width: 50, height: 50)
                        .contentShape(.circle)
                        .overlay {
                            Image(systemName: "mic")
                                .font(DemoFont.roundButton)
                                .symbolVariant(.none)
                                .foregroundStyle(.white, DemoColor.buttonTransparentBackground, .tertiary)
                        }
                }
            }
        })
        .buttonStyle(.borderless)
    }
}

#Preview {
    Group {
        @State var isMuted: Bool = false
        MuteButtonView(isMuted: $isMuted, action: {
            isMuted.toggle()
        }, style: .round)

        @State var isMuted2: Bool = true
        MuteButtonView(isMuted: $isMuted2, action: {
            isMuted2.toggle()
        }, style: .round)
    }
}
