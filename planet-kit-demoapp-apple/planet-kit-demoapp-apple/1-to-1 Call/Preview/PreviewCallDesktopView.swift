#if os(macOS)

import SwiftUI

struct PreviewCallDesktopView: View {

    @StateObject private var viewModel: PreviewCallViewModel

    @EnvironmentObject var deviceEnvironmentManager: DeviceEnvironmentManager
    @EnvironmentObject var callEndRecordManager: CallEndRecordManager
    @EnvironmentObject var navigationRouter: NavigationRouter

    init(callService: any CallService) {
        _viewModel = StateObject(wrappedValue: PreviewCallViewModel(callService: callService))
    }

    private var displayName: String {
        viewModel.peerId
    }

    private var videoOffView: some View {
        HStack {
            Spacer()
            Image(systemName: "video")
                .font(.system(size: 40))
                .symbolVariant(.slash)
                .foregroundStyle(.red, .white, .clear)
            Spacer()
        }
    }

    var body: some View {
        ZStack {
            if viewModel.isPaused {
                videoOffView
            } else {
                VideoView(stream: viewModel.myVideoStream)
                    .onAppear {
                        viewModel.appearPreview()
                    }
                    .onDisappear {
                        viewModel.disappearPreview()
                    }
            }

            VStack {
                Spacer()
                HStack(spacing: 17) {
                    Spacer()

                    ZStack {
                        MuteButtonView(isMuted: $viewModel.isMuted, action: viewModel.toggleMute, style: .round)
                        DevicePickerButton(action: viewModel.pickAudioDevice, style: .round)
                            .offset(x: 26, y: 26)
                    }

                    ZStack {
                        PauseButtonView(isPaused: $viewModel.isPaused, action: viewModel.togglePause, style: .round)
                        DevicePickerButton(action: viewModel.pickVideoDevice, style: .round)
                            .offset(x: 26, y: 26)
                    }

                    Spacer()
                }
                .frame(height: 60)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(displayName)
        .navigationBarBackButtonHidden()
        .background(DemoColor.backgroundOnCall)
        .audioDevicePopup(isShown: $viewModel.isAudioDevicePopup, service: deviceEnvironmentManager.audioDeviceService)
        .videoDevicePopup(isShown: $viewModel.isVideoDevicePopup, service: deviceEnvironmentManager.videoDeviceService)
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
        modifier(AudioDeviceViewModifier(isShown: isShown, service: service, bottom: 35))
    }

    func videoDevicePopup(isShown: Binding<Bool>, service: any VideoDeviceService) -> some View {
        modifier(VideoDeviceViewModifier(isShown: isShown, service: service, bottom: 35))
    }
}

struct PreviewCallDesktopViewPreviewWrapper: View {
    @State private var callService = MockCallService(userAccount: UserAccount.testAccount)
    @StateObject private var callEndRecordManager = CallEndRecordManager()
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var deviceManager = DeviceEnvironmentManager(audioDeviceService: MockAudioDeviceService(), videoDeviceService: MockVideoDeviceService())

    var body: some View {
        PreviewCallDesktopView(callService: callService)
            .environmentObject(callEndRecordManager)
            .environmentObject(navigationRouter)
            .environmentObject(deviceManager)
    }
}

#Preview {
    PreviewCallDesktopViewPreviewWrapper()
}
#endif
