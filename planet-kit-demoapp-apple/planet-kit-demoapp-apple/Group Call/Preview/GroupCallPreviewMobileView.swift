#if os(iOS)
import SwiftUI

struct GroupCallPreviewMobileView: View {
    @StateObject private var viewModel: GroupCallPreviewViewModel
    @Binding private var startRecord: CallStartRecord?

    @EnvironmentObject var navigationRouter: NavigationRouter

    init(roomName: String, previewService: CameraPreviewService, settingsService: SettingsService, startRecord: Binding<CallStartRecord?>) {
        _viewModel = StateObject(wrappedValue: GroupCallPreviewViewModel(roomName: roomName, previewService: previewService, settingsService: settingsService))
        _startRecord = startRecord
    }

    private let enterButtonTitle = LocalizedString.lp_demoapp_group_scenarios_preview_btn.string

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
                .font(.system(size: 30))
                .foregroundColor(.white)
        }
        .buttonStyle(.plain)
    }

    private var toggleMuteButton: some View {
        Button(action: {
            viewModel.toggleMute()
        }) {
            if viewModel.isMuted {
                Image(systemName: "mic")
                    .font(DemoFont.roundButton)
                    .symbolVariant(.slash)
                    .foregroundStyle(.red, .white, .clear)
            } else {
                Image(systemName: "mic")
                    .font(DemoFont.roundButton)
                    .symbolVariant(.none)
                    .foregroundStyle(.white, .secondary, .tertiary)
            }
        }
        .buttonStyle(.borderless)
    }

    private var toggleVideoButton: some View {
        Button(action: {
            viewModel.toggleVideo()
        }) {
            if !viewModel.isVideoEnabled {
                Image(systemName: "video")
                    .font(DemoFont.roundButton)
                    .symbolVariant(.slash)
                    .foregroundStyle(.red, .white)
            } else {
                Image(systemName: "video")
                    .font(DemoFont.roundButton)
                    .symbolVariant(.none)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.borderless)
    }

    private var toggleCameraPositionButton: some View {
        Button(action: {
            viewModel.toggleCameraPosition()
        }) {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .font(DemoFont.roundButton)
                .foregroundColor(.white)
        }
        .buttonStyle(.borderless)
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
        .buttonStyle(.borderless)
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
                    VStack(alignment: .leading) {
                        Text("\(viewModel.roomName)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Camera preview")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    closeButton
                        .padding(10)
                }
                .padding()

                Spacer()

                HStack {
                    toggleMuteButton
                    Spacer()
                    toggleVideoButton
                    Spacer()
                    toggleCameraPositionButton
                }
                .padding(.horizontal)
                .padding(.bottom, 20)

                enterButton
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            viewModel.setNavigationRouter(router: navigationRouter)
            viewModel.startPreview()
        }
        .onDisappear {
            viewModel.setNavigationRouter(router: nil)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .ignoresSafeArea(edges: .bottom)
        .background(DemoColor.backgroundOnGroupCall)
        .navigationDestination(for: GroupCallPreviewDestination.self, destination: { destination in
            switch destination {
            case .enterRoom(let param):
                GroupCallMobileView(service: PlanetGroupCallService(roomId: param.roomName, videoPauseOnStart: param.videoPauseOnStart, muteOnStart: param.muteOnStart, settingsService: viewModel.settingsService), startRecord: $startRecord)
            }
        })
    }
}

struct GroupCallPreviewMobileViewPreviewWrapper: View {
    @State private var previewService = PlanetCameraPreviewService()
    @State private var settingsService = MockSettingsService()
    @State private var startRecord: CallStartRecord?
    @StateObject private var navigationRouter = NavigationRouter()

    var body: some View {
        let roomName = "test"
        GroupCallPreviewMobileView(roomName: roomName, previewService: previewService, settingsService: settingsService, startRecord: $startRecord)
            .environmentObject(navigationRouter)
    }
}

#Preview {
    GroupCallPreviewMobileViewPreviewWrapper()
}
#endif
