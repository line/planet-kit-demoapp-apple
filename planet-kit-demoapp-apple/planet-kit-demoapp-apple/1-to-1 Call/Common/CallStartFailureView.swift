import SwiftUI

struct CallStartFailureView: View {

    @Binding var record: CallStartRecord?

    init(record: Binding<CallStartRecord?>) {
        _record = record
    }

    private let titleText: String = LocalizedString.lp_demoapp_common_error_startfail0.string
    private let peerIdNotFoundText: String = LocalizedString.lp_demoapp_common_error_startfail1.string
    private let okText: String = LocalizedString.lp_demoapp_1to1_scenarios_basic_endcall3.string

    private var titleTextView: some View {
        Text(titleText)
            .font(.system(size: 20).bold())
            .multilineTextAlignment(.center)
            .foregroundColor(Color.title)
    }

    private var startFailureMessage: String {
        switch record?.startFailReason {
        case CallStartRecord.invalidUserIdReason:
            return peerIdNotFoundText
        default:
            return record?.startFailReason ?? ""
        }
    }

    private var descriptionTextView: some View {
        Text(startFailureMessage)
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
                    record = nil
                }, label: {})
                .buttonStyle(FilledButtonStyle(title: okText, active: true, width: 240, height: 48))
            }
            .padding(24)
            .background(Color.background)
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

struct CallStartFailureViewModifier: ViewModifier {

    @Binding private var record: CallStartRecord?

    init(record: Binding<CallStartRecord?>) {
        _record = record
    }

    func body(content: Content) -> some View {
        content
            .disabled((record != nil))
            .overlay {
                if record != nil {
                    VStack {
                        Spacer()
                        CallStartFailureView(record: $record)
                        Spacer()
                    }
                }
            }
    }
}
