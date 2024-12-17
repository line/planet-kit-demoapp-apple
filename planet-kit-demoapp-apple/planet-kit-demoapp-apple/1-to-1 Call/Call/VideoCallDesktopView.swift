#if os(macOS)
import SwiftUI

struct VideoCallDesktopView: View {

    @StateObject private var viewModel: VideoCallViewModel
    @StateObject private var elapsedTimeViewModel: ElapsedTimeViewModel

    @EnvironmentObject var callEndRecordManager: CallEndRecordManager
    @EnvironmentObject var deviceEnvironmentManager: DeviceEnvironmentManager
    @EnvironmentObject var navigationRouter: NavigationRouter

    init(callService: any CallService) {
        _viewModel = StateObject(wrappedValue: VideoCallViewModel(callService: callService))
        _elapsedTimeViewModel = StateObject(wrappedValue: ElapsedTimeViewModel(callService: callService))
    }

    private let okText = LocalizedString.lp_demoapp_setting_popup3.string
    private let cameraAllowGuideText = LocalizedString.lp_demoapp_common_permission_noti2.string

    private var displayName: String {
        var title = viewModel.peerId
        if let time = elapsedTimeViewModel.elapsedTime {
            title += "(\(time))"
        }
        return title
    }

    private var videoOffView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "video")
                    .font(.system(size: 40))
                    .symbolVariant(.slash)
                    .foregroundStyle(.red, .white, .clear)
                Spacer()
            }
            Spacer()
        }
    }

    private var myVideoView: some View {
        ZStack {
            if viewModel.isMyVideoPaused {
                videoOffView
            } else {
                VStack {
                    Spacer(minLength: 0)
                    VideoView(stream: viewModel.myVideoStream, contentMode: .scaleAspectFit)
                        .onAppear {
                            viewModel.appearMyVideo()
                        }
                        .onDisappear {
                            viewModel.disappearMyVideo()
                        }
                    Spacer(minLength: 0)
                }
            }
        }
        .cornerRadius(4)
        .overlay {
            if viewModel.isUserSpeaking {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(lineWidth: 2)
                    .foregroundColor(DemoColor.activeGreen)
            }
        }
    }

    private var peerVideoView: some View {
        ZStack {
            if viewModel.isPeerVideoPaused {
                videoOffView
            } else {
                if viewModel.callState == .connected {
                    VStack {
                        Spacer(minLength: 0)
                        VideoView(stream: viewModel.peerVideoStream, contentMode: .scaleAspectFit, onDrawFirstFrame: {
                            viewModel.didRenderFirstPeerVideo()
                        })
                        Spacer(minLength: 0)
                    }
                } else {
                    PeerProfileDesktopView(viewModel: viewModel)
                }
            }
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

    private var twoVideoViews: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                myVideoView
                MyMuteIconView(isMuted: $viewModel.isMyAudioMuted)
                    .padding(.trailing, 15)
                    .padding(.bottom, 15)
            }
            ZStack(alignment: .bottomTrailing) {
                peerVideoView
                PeerMuteIconView(isMuted: $viewModel.isPeerAudioMuted)
                    .padding(.trailing, 15)
                    .padding(.bottom, 15)
            }
        }
    }

    private var bottomButtons: some View {
        ZStack {
            HStack(alignment: .center, spacing: 20) {
                HStack(alignment: .center, spacing: 0) {
                    MuteButtonView(isMuted: $viewModel.isMyAudioMuted, action: viewModel.toggleMute)
                    DevicePickerButton(action: viewModel.pickAudioDevice, style: .normal)
                }
                HStack(alignment: .center, spacing: 0) {
                    PauseButtonView(isPaused: $viewModel.isMyVideoPaused, action: viewModel.togglePause)
                    DevicePickerButton(action: viewModel.pickVideoDevice, style: .normal)
                }
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
            twoVideoViews
                .padding(.top, 8)
                .padding(.leading, 2)
                .padding(.trailing, 2)
            bottomButtons
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(DemoColor.toolbarBackgroundOnCall)
        }
        .navigationTitle(displayName)
        .navigationBarBackButtonHidden()
        .background(DemoColor.backgroundOnCall)
        .audioDevicePopup(isShown: $viewModel.isAudioDevicePopup, service: deviceEnvironmentManager.audioDeviceService)
        .videoDevicePopup(isShown: $viewModel.isVideoDevicePopup, service: deviceEnvironmentManager.videoDeviceService)
        .alert(Text(""), isPresented: $viewModel.isCameraUnauthorized) {
            Button(okText) {
                viewModel.openAppSettingsForCamera()
            }
        } message: {
            Text(cameraAllowGuideText)
        }
        .onChange(of: viewModel.callState) { newValue in
            viewModel.navigateWithCallState(state: newValue)
        }
        .onAppear {
            viewModel.setCallEndRecordManager(manager: callEndRecordManager)
            viewModel.setNavigationRouter(router: navigationRouter)
            viewModel.navigateWithCallState(state: viewModel.callState)
            viewModel.bindVideoDeviceService(deviceEnvironmentManager.videoDeviceService)
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

    func videoDevicePopup(isShown: Binding<Bool>, service: any VideoDeviceService) -> some View {
        modifier(VideoDeviceViewModifier(isShown: isShown, service: service, bottom: 50))
    }
}

struct VideoCallDesktopViewPreviewWrapper: View {
    @State private var callService = MockCallService(userAccount: UserAccount.testAccount)
    @StateObject private var callEndRecordManager = CallEndRecordManager()
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var deviceManager = DeviceEnvironmentManager(audioDeviceService: MockAudioDeviceService(), videoDeviceService: MockVideoDeviceService())

    var body: some View {
        VideoCallDesktopView(callService: callService)
            .environmentObject(callEndRecordManager)
            .environmentObject(navigationRouter)
            .environmentObject(deviceManager)
    }
}

#Preview {
    VideoCallDesktopViewPreviewWrapper()
}
#endif
