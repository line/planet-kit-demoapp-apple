#if os(macOS)
import SwiftUI

struct GroupCallPreviewDesktopView: View {
    @StateObject private var viewModel: GroupCallPreviewViewModel
    @Binding private var startRecord: CallStartRecord?

    @EnvironmentObject var deviceEnvironmentManager: DeviceEnvironmentManager
    @EnvironmentObject var navigationRouter: NavigationRouter

    private let previewTitle = LocalizedString.lp_demoapp_group_scenarios_preview_title.string
    private let enterButtonTitle = LocalizedString.lp_demoapp_group_scenarios_preview_btn.string

    init(roomName: String, previewService: CameraPreviewService, settingsService: SettingsService, startRecord: Binding<CallStartRecord?>) {
        _viewModel = StateObject(wrappedValue: GroupCallPreviewViewModel(roomName: roomName, previewService: previewService, settingsService: settingsService))
        _startRecord = startRecord
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

    private var closeButton: some View {
        Button(action: {
            viewModel.exit()
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 20))
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }

    private var audioButtons: some View {
        ZStack {
            toggleMuteButton
            pickAudioDeviceButton
                .offset(x: 26, y: 26)
        }
    }

    private var videoButtons: some View {
        ZStack {
            toggleVideoButton
            pickVideoDeviceButton
                .offset(x: 26, y: 26)
        }
    }

    private var toggleMuteButton: some View {
        Button(action: {
            viewModel.toggleMute()
        }) {
            if viewModel.isMuted {
                Circle()
                    .background(.clear)
                    .foregroundColor(DemoColor.buttonTransparentBackground)
                    .overlay {
                        Image(systemName: "mic")
                            .font(DemoFont.roundButton)
                            .symbolVariant(.slash)
                            .foregroundStyle(.red, .white, .clear)
                    }
            } else {
                Circle()
                    .background(.clear)
                    .foregroundColor(DemoColor.buttonTransparentBackground)
                    .overlay {
                        Image(systemName: "mic")
                            .font(DemoFont.roundButton)
                            .symbolVariant(.none)
                            .foregroundStyle(.white, DemoColor.buttonTransparentBackground, .tertiary)
                    }
            }
        }
        .frame(width: 50, height: 50)
        .contentShape(.circle)
        .buttonStyle(.plain)
    }

    private var toggleVideoButton: some View {
        Button(action: {
            viewModel.toggleVideo()
        }) {
            if !viewModel.isVideoEnabled {
                Circle()
                    .background(.clear)
                    .foregroundColor(DemoColor.buttonTransparentBackground)
                    .overlay {
                        Image(systemName: "video")
                            .font(DemoFont.roundButton)
                            .symbolVariant(.slash)
                            .foregroundStyle(.red, .white, .clear)
                    }
            } else {
                Circle()
                    .background(.clear)
                    .foregroundColor(DemoColor.buttonTransparentBackground)
                    .overlay {
                        Image(systemName: "video")
                            .font(DemoFont.roundButton)
                            .symbolVariant(.none)
                            .foregroundStyle(.white, DemoColor.buttonTransparentBackground, .clear)
                    }
            }
        }
        .frame(width: 50, height: 50)
        .contentShape(.circle)
        .buttonStyle(.plain)
    }

    private var pickAudioDeviceButton: some View {
        Button(action: {
            viewModel.pickAudioDevice()
        }) {
            Image(systemName: "chevron.up")
                .font(DemoFont.normalButton)
                .symbolVariant(.fill.circle)
                .scaledToFit()
                .foregroundStyle(.white, .white, .tertiary)
        }
        .frame(width: 30, height: 30)
        .buttonStyle(.plain)
        .contentShape(.circle)
    }

    private var pickVideoDeviceButton: some View {
        Button(action: {
            viewModel.pickVideoDevice()
        }) {
            Image(systemName: "chevron.up")
                .font(DemoFont.normalButton)
                .symbolVariant(.fill.circle)
                .scaledToFit()
                .foregroundStyle(.white, .white, .tertiary)
        }
        .frame(width: 30, height: 30)
        .buttonStyle(.plain)
        .contentShape(.circle)
    }

    private var enterButton: some View {
        Button(action: {
            viewModel.enterRoom()
        }) {
            Text(enterButtonTitle)
                .font(.headline)
                .foregroundColor(.white)
                .padding()
        }
        .background(DemoColor.activeGreen)
        .buttonStyle(.plain)
        .cornerRadius(10)
    }

    var body: some View {
        ZStack {
            if viewModel.isVideoEnabled {
                VideoView(stream: viewModel.stream)
            } else {
                videoOffView
            }
            VStack {
                HStack {
                    Spacer()
                    closeButton
                }
                .padding()

                Spacer()

                HStack(spacing: 17) {
                    Spacer()
                    audioButtons
                    videoButtons
                    enterButton
                    Spacer()
                }
                .frame(height: 60)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(previewTitle)
        .background(DemoColor.backgroundOnGroupCall)
        .audioDevicePopup(isShown: $viewModel.isAudioDevicePopup, service: deviceEnvironmentManager.audioDeviceService)
        .videoDevicePopup(isShown: $viewModel.isVideoDevicePopup, service: deviceEnvironmentManager.videoDeviceService)
        .onAppear {
            viewModel.setNavigationRouter(router: navigationRouter)
            viewModel.startPreview()
            viewModel.bindVideoDeviceService(deviceEnvironmentManager.videoDeviceService)
        }
        .onDisappear {
            viewModel.setNavigationRouter(router: nil)
        }
        .navigationDestination(for: GroupCallPreviewDestination.self, destination: { destination in
            switch destination {
            case .enterRoom(let param):
                GroupCallDesktopView(service: PlanetGroupCallService(roomId: param.roomName, videoPauseOnStart: param.videoPauseOnStart, muteOnStart: param.muteOnStart, settingsService: viewModel.settingsService), startRecord: $startRecord)
            }
        })
    }
}

fileprivate extension View {
    func audioDevicePopup(isShown: Binding<Bool>, service: any AudioDeviceService) -> some View {
        modifier(AudioDeviceViewModifier(isShown: isShown, service: service, bottom: 35))
    }

    func videoDevicePopup(isShown: Binding<Bool>, service: any VideoDeviceService) -> some View {
        modifier(VideoDeviceViewModifier(isShown: isShown, service: service, bottom: 35))
    }
}

struct GroupCallPreviewDesktopViewPreviewWrapper: View {
    @State private var previewService = PlanetCameraPreviewService()
    @State private var settingsService = MockSettingsService()
    @State private var startRecord: CallStartRecord?
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var deviceManager = DeviceEnvironmentManager(audioDeviceService: MockAudioDeviceService(), videoDeviceService: MockVideoDeviceService())
    var body: some View {
        let roomName = "test"
        GroupCallPreviewDesktopView(roomName: roomName, previewService: previewService, settingsService: settingsService, startRecord: $startRecord)
            .environmentObject(deviceManager)
            .environmentObject(navigationRouter)
    }
}

#Preview {
    GroupCallPreviewDesktopViewPreviewWrapper()
}
#endif
