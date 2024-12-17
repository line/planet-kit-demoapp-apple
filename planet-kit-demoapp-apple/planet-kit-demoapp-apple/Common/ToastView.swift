import SwiftUI

struct ToastView: View {
    let title: String
    let message: String
    let buttonText: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button(action: onDismiss, label: {})
                .buttonStyle(FilledButtonStyle(title: buttonText, active: true, width: 240, height: 48))
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
}

struct ToastViewModifier: ViewModifier {
    @Binding private var showToast: Bool

    let title: String
    let message: String
    let buttonText: String

    init(showToast: Binding<Bool>, title: String, message: String, buttonText: String) {
        _showToast = showToast
        self.title = title
        self.message = message
        self.buttonText = buttonText
    }

    func body(content: Content) -> some View {
        content
            .disabled(showToast)
            .overlay {
                if showToast {
                    VStack(alignment: .center) {
                        ToastView(title: "Start Fail", message: "failed to start", buttonText: "OK", onDismiss: {
                            showToast = false
                        })
                    }
                }
            }
    }
}

struct ToastViewWrapper: View {
    @State private var showToast = true

    var body: some View {
        VStack(alignment: .center) {

        }
        .toastViewModifier(showToast: $showToast, title: "Start Fail", message: "failed to start", buttonText: "OK")
    }
}

private extension View {
    func toastViewModifier(showToast: Binding<Bool>, title: String, message: String, buttonText: String) -> some View {
        modifier(ToastViewModifier(showToast: showToast, title: title, message: message, buttonText: buttonText))
    }
}

#Preview {
    ToastViewWrapper()
}
