import SwiftUI

struct PauseButtonView: View {

    enum Style {
        case normal
        case round
    }

    @Binding var isPaused: Bool
    private let action: () -> Void
    private let style: Style

    init(isPaused: Binding<Bool>, action: @escaping () -> Void, style: Style = .normal) {
        _isPaused = isPaused
        self.action = action
        self.style = style
    }

    var body: some View {
        Button(action: action, label: {
            switch style {
            case .normal:
                if isPaused {
                    Image(systemName: "video")
                        .font(DemoFont.normalButton)
                        .symbolVariant(.slash)
                        .foregroundStyle(.red, .white)
                        .frame(width: 50, height: 50)
                        .contentShape(.circle)
                } else {
                    Image(systemName: "video")
                        .font(DemoFont.normalButton)
                        .symbolVariant(.none)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .contentShape(.circle)
                }
            case .round:
                if isPaused {
                    Circle()
                        .background(.clear)
                        .foregroundColor(DemoColor.buttonTransparentBackground)
                        .frame(width: 50, height: 50)
                        .contentShape(.circle)
                        .overlay {
                            Image(systemName: "video")
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
                            Image(systemName: "video")
                                .font(DemoFont.roundButton)
                                .symbolVariant(.none)
                                .foregroundStyle(.white, DemoColor.buttonTransparentBackground, .clear)
                        }
                }
            }
        })
        .buttonStyle(.borderless)
    }
}

#Preview {
    Group {
        @State var isPaused: Bool = false
        PauseButtonView(isPaused: $isPaused, action: {
            isPaused.toggle()
        }, style: .round)

        @State var isPaused2: Bool = true
        PauseButtonView(isPaused: $isPaused2, action: {
            isPaused2.toggle()
        }, style: .round)
    }
}
