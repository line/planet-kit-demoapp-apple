import SwiftUI

enum IncomingCallViewDestination {
    case audioCall
    case videoCall
}

enum IncomingCallResponse {
    case accept
    case decline
}

struct IncomingCallInfo: Equatable {
    let isVideoCall: Bool
    let callerName: String
}

struct IncomingCallDesktopView: View {
    let isVideoCall: Bool
    let callerName: String
    let action: (IncomingCallResponse) -> Void

    private var incomingCallText: String {
        if isVideoCall {
            return LocalizedString.lp_demoapp_1to1_noti_video.string
        } else {
            return LocalizedString.lp_demoapp_1to1_noti_voice.string
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(callerName)
                    .font(.system(size: 20))
                    .foregroundColor(DemoColor.textOnCall)

                Text(incomingCallText)
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 20)

            Spacer()

            HStack {
                DeclineButton(action: {
                    action(.decline)
                }, iconColor: DemoColor.buttonIconOnIncomingCall)
                AcceptButton(action: {
                    action(.accept)
                }, iconColor: DemoColor.buttonIconOnIncomingCall)
            }
            .padding(20)
        }
        .background(DemoColor.backgroundOnIncomingCall)
        .cornerRadius(10)
        .shadow(color: DemoColor.shadowOnIncomingCall, radius: 5, x: 0, y: 2)
    }
}

struct IncomingCallViewModifier: ViewModifier {
    @Binding var incomingCallInfo: IncomingCallInfo?
    let action: (IncomingCallResponse) -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
            if let info = incomingCallInfo {
                VStack {
                    IncomingCallDesktopView(isVideoCall: info.isVideoCall, callerName: info.callerName, action: action)
                        .padding(20)
                    Spacer()
                }
            }
        }
    }
}

struct IncomingCallDesktopViewWrapper: View {
    @State private var incomingCallInfo: IncomingCallInfo?

    var body: some View {
        VStack {
            Button(action: {
                incomingCallInfo = IncomingCallInfo(isVideoCall: true, callerName: "test")
            }, label: {
                Text("show incoming view")
            })
        }
        .modifier(IncomingCallViewModifier(incomingCallInfo: $incomingCallInfo, action: { _ in
            incomingCallInfo = nil
        }))
    }
}

#Preview {
    ZStack {
        IncomingCallDesktopViewWrapper()
            .frame(width: 400, height: 300)
    }
}
