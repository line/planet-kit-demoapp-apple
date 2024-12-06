import SwiftUI

struct PeerProfileMobileView: View {

    @StateObject private var viewModel: CallViewModel

    init(viewModel: CallViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center) {
                ProfileNoImage(size: 84)

                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                    Text(viewModel.peerId)
                        .foregroundColor(DemoColor.textOnCall)
                }
                .padding(.top, 5)
                .overlay {
                    if viewModel.callState == .connected {
                        PeerMuteIconView(isMuted: $viewModel.isPeerAudioMuted)
                            .offset(CGSize(width: 0, height: 20.0))
                    }
                }

                if viewModel.callState == .connecting {
                    ConnectingDotsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            Spacer()
        }
    }
}

#Preview {
    VStack {
        let callService = MockCallService(userAccount: UserAccount.testAccount)
        let viewModel = CallViewModel(callService: callService)
        // viewModel.callState = .connecting
        PeerProfileMobileView(viewModel: viewModel)
            .background(DemoColor.backgroundDark)
    }
}
