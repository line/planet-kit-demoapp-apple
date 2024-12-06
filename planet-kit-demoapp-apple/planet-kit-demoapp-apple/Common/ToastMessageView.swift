import SwiftUI

struct ToastMessageView: View {
    let message: String
    let showOnTop: Bool

    var body: some View {
        VStack {
            if showOnTop {
                HStack {
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                }
                .padding(.top, 10)
                .transition(.move(edge: .top))
                Spacer()
            } else {
                Spacer()
                HStack {
                    Text(message)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                }
                .padding(.bottom, 50)
                .transition(.move(edge: .bottom))
            }
        }
    }
}

struct ToastMessageViewModifier: ViewModifier {
    @Binding private var showToast: Bool
    let message: String
    let showOnTop: Bool

    private let toastDurationSec: Double = 5.0

    init(showToast: Binding<Bool>, message: String, showOnTop: Bool) {
        _showToast = showToast
        self.message = message
        self.showOnTop = showOnTop
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if showToast {
                    ToastMessageView(message: message, showOnTop: showOnTop)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + toastDurationSec) {
                                withAnimation {
                                    showToast = false
                                }
                            }
                        }
                }
            }
    }
}

struct ToastMessageListViewModifier: ViewModifier {
    @Binding private var messages: [String]

    @State private var currentMessage: String?

    private let toastDurationSec: Double = 5.0
    private let showOnTop: Bool

    init(messages: Binding<[String]>, showOnTop: Bool) {
        _messages = messages
        self.showOnTop = showOnTop
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if let message = currentMessage {
                    ToastMessageView(message: message, showOnTop: showOnTop)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + toastDurationSec) {
                                withAnimation {
                                    currentMessage = nil
                                }
                            }
                        }
                }
            }
            .onChange(of: messages) { _ in
                if messages.count > 0 {
                    currentMessage = messages.removeFirst()
                }
            }
    }
}

private extension View {
    func toastMessageViewModifier(showToast: Binding<Bool>, message: String, showOnTop: Bool = false) -> some View {
        modifier(ToastMessageViewModifier(showToast: showToast, message: message, showOnTop: showOnTop))
    }

    func toastMessageListViewModifier(messages: Binding<[String]>, showOnTop: Bool = false) -> some View {
        modifier(ToastMessageListViewModifier(messages: messages, showOnTop: showOnTop))
    }
}

struct ToastMessageViewWrapper: View {
    @State var showToast = false
    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                withAnimation {
                    showToast.toggle()
                }
            }, label: {
                Text("Toggle Toast")
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toastMessageViewModifier(showToast: $showToast, message: "{{User name}} has left the group call.", showOnTop: false)
    }
}

struct ToastMessageListViewWrapper: View {
    @State private var toastMessages: [String] = []
    var body: some View {
        VStack(alignment: .center) {
            Button(action: {
                withAnimation {
                    toastMessages.append("toast message \(Date().description)")
                }
            }, label: {
                Text("add Toast")
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .toastMessageListViewModifier(messages: $toastMessages)
    }
}

#Preview {
    //    ToastMessageViewWrapper()
    ToastMessageListViewWrapper()
}
