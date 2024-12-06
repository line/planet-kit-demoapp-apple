import SwiftUI

struct ElapsedTimeView: View {

    @StateObject private var viewModel: ElapsedTimeViewModel

    private let showIcon: Bool

    init(callService: any CallService, showIcon: Bool = false) {
        _viewModel = StateObject(wrappedValue: ElapsedTimeViewModel(callService: callService))
        self.showIcon = showIcon
    }

    var body: some View {
        if let elapsedTime = viewModel.elapsedTime {
            if showIcon {
                Label(elapsedTime, systemImage: "clock")
                    .labelStyle(.titleAndIcon)
                    .font(.system(size: 17))
                    .foregroundColor(DemoColor.textOnCall)
            } else {
                Text(elapsedTime)
                    .font(.system(size: 17))
                    .foregroundColor(DemoColor.textOnCall)
            }
        } else {
            Text("")
                .font(.system(size: 17))
                .foregroundColor(DemoColor.textOnCall)
        }
    }
}

#Preview {
    ZStack {
        let callService = MockCallService(userAccount: UserAccount.testAccount)
        ElapsedTimeView(callService: callService, showIcon: true)

        ElapsedTimeView(callService: callService, showIcon: false)
    }
}
