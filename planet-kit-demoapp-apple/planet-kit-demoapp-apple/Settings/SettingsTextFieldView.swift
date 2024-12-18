import SwiftUI

struct SettingsTextFieldView: View {
    let title: String
    let placeHolder: String
    let description: String
    let disabled: Bool

    @Binding var text: String
    let onChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                Text(title)
                    .font(DemoFont.default.weight(.bold))
                    .foregroundColor(Color.inputItemTitle)
                Text("*")
                    .font(DemoFont.default.weight(.bold))
                    .foregroundColor(DemoColor.required)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            TextField(placeHolder, text: $text)
                .padding()
                .cornerRadius(5)
                .autocorrectionDisabled()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(DemoColor.gray300, lineWidth: 1)
                )
                .onChange(of: text) { newValue in
                    onChange(newValue)
                }
                .disabled(disabled)
                #if os(iOS)
                .autocapitalization(.none)
                #endif

            Text(description)
                .font(DemoFont.small)
                .foregroundColor(DemoColor.gray500)
                .multilineTextAlignment(.leading)
        }
    }
}

struct SettingsTextFieldViewWrapper: View {
    @State private var text = ""
    var body: some View {
        SettingsTextFieldView(title: "preview", placeHolder: "preview", description: "preview", disabled: false, text: $text, onChange: { newValue in
            AppLog.v("onchange \(newValue)")
        })
    }

}
#Preview {
    SettingsTextFieldViewWrapper()
}
