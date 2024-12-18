import SwiftUI

struct TitleIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
            Spacer()
        }
    }
}

struct FilledLabelStyle: LabelStyle {
    let active: Bool
    let width: CGFloat?
    let height: CGFloat?

    private var backgroundColor: Color {
        active ? DemoColor.activeGreen : DemoColor.disableGray
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 0) { // EN / Text / L 17 / Bold
            configuration.title
                .font(DemoFont.buttons)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .frame(width: width, height: height, alignment: .center)
        .background(backgroundColor)
        .cornerRadius(5)
    }
}

struct OutlinedLabelStyle: LabelStyle {
    let titleOnly: Bool = true
    let active: Bool
    let width: CGFloat
    let height: CGFloat

    private var textColor: Color {
        active ? DemoColor.activeGreen : DemoColor.disableGray
    }

    private var outlineColor: Color {
        active ? DemoColor.activeGreen : DemoColor.disableGray
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center) { // EN / Text / L 17 / Bold
            if titleOnly {
                configuration.title
                    .font(DemoFont.buttons)
                    .multilineTextAlignment(.center)
                    .foregroundColor(textColor)
            } else {
                Label(configuration)
                    .font(DemoFont.buttons)
                    .foregroundColor(textColor)
            }
        }
        .frame(width: width, height: height, alignment: .center)
        .cornerRadius(5)
        .contentShape(.containerRelative)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .inset(by: 0.5)
                .stroke(outlineColor, lineWidth: 1)
        )
    }
}
