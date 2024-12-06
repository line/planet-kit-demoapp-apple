import SwiftUI

struct PeerProfileDesktopView: View {

    @StateObject private var viewModel: CallViewModel

    init(viewModel: CallViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let callingText = LocalizedString.lp_demoapp_1to1_scenarios_basic_calling.string

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center) {
                ProfileNoImage(size: 84)

                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                    if viewModel.callState == .connecting {
                        Text(callingText)
                            .foregroundColor(DemoColor.textOnCall)
                    }
                }
                .padding(.top, 5)
                .overlay {
                    if viewModel.callState == .connected {
                        PeerMuteIconView(isMuted: $viewModel.isPeerAudioMuted)
                            .offset(CGSize(width: 0, height: 20.0))
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            Spacer()
        }
        .cornerRadius(4)
        .overlay {
            if viewModel.isPeerSpeaking {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(lineWidth: 2)
                    .foregroundColor(DemoColor.activeGreen)
            }
        }
    }
}
