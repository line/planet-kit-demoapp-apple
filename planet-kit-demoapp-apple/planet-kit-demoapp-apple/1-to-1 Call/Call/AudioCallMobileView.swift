#if os(iOS)
import SwiftUI

struct AudioCallMobileView: View {
    @EnvironmentObject var callEndRecordManager: CallEndRecordManager
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel: AudioCallViewModel

    init(callService: any CallService) {
        _viewModel = StateObject(wrappedValue: AudioCallViewModel(callService: callService))
    }

    private var displayName: String {
        viewModel.peerId
    }

    private let incomingCallText = LocalizedString.lp_demoapp_1to1_noti_voice.string
    private let callingText = LocalizedString.lp_demoapp_1to1_scenarios_basic_calling.string
    private let peerAudioMutedText = LocalizedString.lp_demoapp_1to1_scenarios_basic_inacall1.string

    private var peerProfileImageView: some View {
        VStack(alignment: .center) {
            ProfileNoImage(size: 140)
                .overlay {
                    if viewModel.isPeerSpeaking {
                        Circle()
                            .strokeBorder(lineWidth: 3)
                            .foregroundColor(DemoColor.activeGreen)
                    }
                }
        }
    }

    private var peerNameView: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(displayName)
                .font(.system(size: 26))
                .foregroundColor(DemoColor.textOnCall)

            if viewModel.callState == .connecting {
                Text(callingText)
                    .font(.system(size: 17))
                    .foregroundColor(DemoColor.textOnCall)
            } else {
                ElapsedTimeView(callService: viewModel.callService, showIcon: false)
            }
        }
    }

    private var middleButtons: some View {
        HStack {
            Spacer()
            MuteButtonView(isMuted: $viewModel.isMyAudioMuted, action: viewModel.toggleMute)
            Spacer()
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: 20) {
            Spacer()
            DisconnectCircleButton(action: viewModel.disconnect)
            Spacer()
        }
    }

    private var topMarginOfProfile: CGFloat {
        return mainScreenSize.height * 0.14
    }

    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                peerProfileImageView
                    .padding(.top, topMarginOfProfile)

                peerNameView

                Spacer()

                middleButtons
                    .padding(.bottom, 20)

                bottomButtons
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                    .padding(.bottom, 55)
            }

            if viewModel.isPeerAudioMuted {
                Text(peerAudioMutedText)
                    .font(.system(size: 17))
                    .foregroundColor(DemoColor.textOnCall)
            }
        }
        .background(DemoColor.backgroundDark)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.all)
        .onChange(of: viewModel.callState) { newValue in
            viewModel.navigateWithCallState(state: newValue)
        }
        .onAppear {
            viewModel.setCallEndRecordManager(manager: callEndRecordManager)
            viewModel.setNavigationRouter(router: navigationRouter)
            viewModel.navigateWithCallState(state: viewModel.callState)
        }
        .onDisappear {
            viewModel.setCallEndRecordManager(manager: nil)
            viewModel.setNavigationRouter(router: nil)
        }
    }
}

struct AudioCallMobileViewPreviewWrapper: View {
    @State private var callService = MockCallService(userAccount: UserAccount.testAccount)
    @StateObject private var callEndRecordManager = CallEndRecordManager()
    @StateObject private var navigationRouter = NavigationRouter()
    var body: some View {
        AudioCallMobileView(callService: callService)
            .environmentObject(callEndRecordManager)
            .environmentObject(navigationRouter)
            .onAppear {
                callService.connected()
            }
    }
}

#Preview {
    AudioCallMobileViewPreviewWrapper()
}
#endif
