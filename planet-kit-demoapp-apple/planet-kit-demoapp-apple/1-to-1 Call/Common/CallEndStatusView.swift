import SwiftUI

struct CallEndStatusView: View {

    let record: CallEndRecord
    let action: () -> Void

    private let titleText: String = LocalizedString.lp_demoapp_1to1_scenarios_basic_endcall1.string
    private let descriptionText: String = LocalizedString.lp_demoapp_1to1_scenarios_basic_endcall2.string
    private let okText: String = LocalizedString.lp_demoapp_1to1_scenarios_basic_endcall3.string

    private var titleTextView: some View {
        Text(titleText)
            .font(.system(size: 20).bold())
            .multilineTextAlignment(.center)
            .foregroundColor(.primary)
    }

    private var descriptionTextView: some View {
        Text("\(descriptionText)\n\(record.disconnectReason)")
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
            .foregroundColor(DemoColor.hintGuide)
            .fixedSize(horizontal: false, vertical: true)
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(spacing: 20) {
                titleTextView
                descriptionTextView

                Button(action: action, label: {})
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
        .transition(.scale)
        .shadow(color: .primary.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

struct CallEndStatusListViewModifier: ViewModifier {

    @ObservedObject var manager: CallEndRecordManager

    func body(content: Content) -> some View {
        content
            .disabled(!manager.records.isEmpty)
            .overlay {
                if let record = manager.records.first {
                    VStack {
                        Spacer()
                        CallEndStatusView(record: record) {
                            manager.records.removeFirst()
                        }
                        Spacer()
                    }
                }
            }
    }
}

struct CallEndStatusViewWrapper: View {
    @StateObject private var manager = CallEndRecordManager()
    var body: some View {
        VStack {
            Button(action: {
                manager.records.append(CallEndRecord(callType: .oneToOneCall("test"), disconnectReason: "test"))
            }, label: {
                Text("test button")
            })
        }
        .modifier(CallEndStatusListViewModifier(manager: manager))
        //        .frame(width: 400, height: 200)
    }
}
#Preview {
    CallEndStatusViewWrapper()
}
