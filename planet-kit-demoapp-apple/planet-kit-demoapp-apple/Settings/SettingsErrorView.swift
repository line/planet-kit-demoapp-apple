import SwiftUI

struct SettingsErrorView: View {

    @Binding private var description: String?

    init(description: Binding<String?>) {
        _description = description
    }

    private let titleText: String = LocalizedString.lp_demoapp_setting_popup1.string
    private let okText: String = LocalizedString.lp_demoapp_setting_popup3.string

    private var titleTextView: some View {
        Text(titleText)
            .font(.system(size: 20).bold())
            .multilineTextAlignment(.center)
            .foregroundColor(.primary)
    }

    private var descriptionTextView: some View {
        Text("\(description ?? "")")
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(DemoColor.hintGuide)
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(spacing: 20) {
                titleTextView
                descriptionTextView

                Button(action: {
                    description = nil
                }, label: {})
                .buttonStyle(FilledButtonStyle(title: okText, active: true, width: 240, height: 48))
            }
            .padding(24)
            .background(.background)
            .foregroundColor(.primary)
            .cornerRadius(12)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.primary, lineWidth: 1)
            }
        }
        .shadow(color: .primary.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct SettingsErrorViewModifier: ViewModifier {

    @Binding private var description: String?

    init(description: Binding<String?>) {
        _description = description
    }

    func body(content: Content) -> some View {
        content
            .disabled((description != nil))
            .overlay {
                if description != nil {
                    VStack {
                        Spacer()
                        SettingsErrorView(description: $description)
                        Spacer()
                    }
                }
            }
    }
}

#Preview {
    ZStack {
        @State var description: String? = "Error"
        SettingsErrorView(description: $description)
    }
}
