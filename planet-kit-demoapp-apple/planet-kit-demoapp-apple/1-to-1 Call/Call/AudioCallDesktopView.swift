#if os(macOS)
import SwiftUI

struct AudioCallDesktopView: View {

    @StateObject private var viewModel: AudioCallViewModel
    @StateObject private var elapsedTimeViewModel: ElapsedTimeViewModel

    @EnvironmentObject var callEndRecordManager: CallEndRecordManager
    @EnvironmentObject var deviceEnvironmentManager: DeviceEnvironmentManager
    @EnvironmentObject var navigationRouter: NavigationRouter

    init(callService: any CallService) {
        _viewModel = StateObject(wrappedValue: AudioCallViewModel(callService: callService))
        _elapsedTimeViewModel = StateObject(wrappedValue: ElapsedTimeViewModel(callService: callService))
    }

    private var displayName: String {
        var title = viewModel.peerId
        if let time = elapsedTimeViewModel.elapsedTime {
            title += "(\(time))"
        }
        return title
    }

    private var bottomButtons: some View {
        ZStack {
            HStack(alignment: .center, spacing: 0) {
                MuteButtonView(isMuted: $viewModel.isMyAudioMuted, action: viewModel.toggleMute)
                DevicePickerButton(action: viewModel.pickAudioDevice, style: .normal)
            }

            HStack {
                Spacer()
                DisconnectRoundButton(action: viewModel.disconnect)
                    .padding(.trailing, 20)
            }
        }
    }

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
                MyProfileDesktopView(viewModel: viewModel)
                PeerProfileDesktopView(viewModel: viewModel)
            }

            bottomButtons
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(DemoColor.toolbarBackgroundOnCall)
        }
        .navigationTitle(displayName)
        .navigationBarBackButtonHidden()
        .background(DemoColor.backgroundOnCall)
        .audioDevicePopup(isShown: $viewModel.isAudioDevicePopup, service: deviceEnvironmentManager.audioDeviceService)
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

private extension View {
    func audioDevicePopup(isShown: Binding<Bool>, service: any AudioDeviceService) -> some View {
        modifier(AudioDeviceViewModifier(isShown: isShown, service: service, bottom: 50))
    }
}

struct AudioCallDesktopViewPreviewWrapper: View {
    @State private var callService = MockCallService(userAccount: UserAccount.testAccount)
    @StateObject private var callEndRecordManager = CallEndRecordManager()
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var deviceManager = DeviceEnvironmentManager(audioDeviceService: MockAudioDeviceService(), videoDeviceService: MockVideoDeviceService())

    var body: some View {
        AudioCallDesktopView(callService: callService)
            .environmentObject(callEndRecordManager)
            .environmentObject(navigationRouter)
            .environmentObject(deviceManager)
    }
}

#Preview {
    AudioCallDesktopViewPreviewWrapper()
}
#endif
