#if os(iOS)
import SwiftUI
import UIKit

struct VideoCallMobileView: View {
    @EnvironmentObject var callEndRecordManager: CallEndRecordManager
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel: VideoCallViewModel

    init(callService: any CallService) {
        _viewModel = StateObject(wrappedValue: VideoCallViewModel(callService: callService))
    }

    init(viewModel: VideoCallViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let peerCameraOffText = LocalizedString.lp_demoapp_1to1_scenarios_basic_inacall2.string
    private let incomingCallText = LocalizedString.lp_demoapp_1to1_noti_video.string

    private var displayName: String {
        viewModel.peerId
    }

    private var isPeerVideoAvailable: Bool {
        viewModel.isFirstPeerVideoRendered || viewModel.isPeerVideoPaused
    }

    private var peerProfileImageView: some View {
        VStack(alignment: .center) {
            ProfileNoImage(size: 140)
        }
    }

    private var peerNameView: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(displayName)
                .font(.system(size: 26))
                .foregroundColor(DemoColor.textOnCall)
        }
    }

    private var myVideoOffView: some View {
        VStack(alignment: .leading) {
            Image(systemName: "video")
                .font(.system(size: 18))
                .symbolVariant(.slash)
                .foregroundStyle(.red, .white, .clear)
                .frame(width: 40, height: 40, alignment: .center)
        }
        .frame(width: 100, height: 150)
        .cornerRadius(3)
        .background(DemoColor.videoOffDeep)
    }

    private var myVideoView: some View {
        ZStack {
            if viewModel.isMyVideoPaused {
                myVideoOffView
            } else {
                VideoView(stream: viewModel.myVideoStream)
                    .background(DemoColor.backgroundDark)
                    .onAppear {
                        viewModel.appearMyVideo()
                    }
                    .onDisappear {
                        viewModel.disappearMyVideo()
                    }
            }
        }
    }

    @ViewBuilder
    private var peerVideoView: some View {
        if viewModel.isPeerVideoPaused {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Text(peerCameraOffText)
                        .font(.system(size: 17))
                        .foregroundColor(DemoColor.textOnCall)
                    Spacer()
                }
                Spacer()
            }
            .background(DemoColor.videoOffDeep)
        } else {
            VideoView(stream: viewModel.peerVideoStream, onDrawFirstFrame: {
                viewModel.didRenderFirstPeerVideo()
            })
        }
    }

    @ViewBuilder
    private var bottomButtons: some View {
        VStack(spacing: 50) {
            if viewModel.callState == .connected {
                HStack(alignment: .bottom, spacing: 60) {
                    MuteButtonView(isMuted: $viewModel.isMyAudioMuted, action: viewModel.toggleMute)
                    PauseButtonView(isPaused: $viewModel.isMyVideoPaused, action: viewModel.togglePause)
                    CameraSwitchButton(action: viewModel.switchCameraPosition)
                }
            }

            HStack(spacing: 20) {
                Spacer()
                DisconnectCircleButton(action: viewModel.disconnect)
                Spacer()
            }
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            peerVideoView

            if viewModel.isIncomingCall == false {
                myVideoView
                    .padding(.leading, isPeerVideoAvailable ? 40: 0)
                    .padding(.top, isPeerVideoAvailable ? 90: 0)
                    .frame(width: isPeerVideoAvailable ? 150: nil,
                           height: isPeerVideoAvailable ? 250: nil)
                    .cornerRadius(3.0)
                    .animation(.easeInOut(duration: 0.5), value: isPeerVideoAvailable)
            } else {
                myVideoView
                    .padding(.leading, 40)
                    .padding(.top, 90)
                    .frame(width: 150, height: 250)
                    .cornerRadius(3.0)
            }

            if viewModel.callState != .connected {
                if viewModel.isIncomingCall {
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            peerProfileImageView
                                .padding(.top, 161)

                            peerNameView
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    PeerProfileMobileView(viewModel: viewModel)
                        .frame(width: 150, height: 250)
                        .padding(.leading, 20)
                        .padding(.top, 45)
                }
            }

            VStack {
                HStack(alignment: .top) {
                    ElapsedTimeView(callService: viewModel.callService, showIcon: true)
                }
                .padding(.top, 90)

                Spacer()
                HStack(alignment: .center) {
                    Spacer()
                    bottomButtons
                        .padding(.bottom, 55)
                }
            }
        }
        .background(DemoColor.backgroundDark)
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.all)
        .onChange(of: viewModel.callState) { newValue in
            viewModel.navigateWithCallState(state: newValue)
        }
        .onAppear {
            #if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = true
            #endif
            viewModel.setCallEndRecordManager(manager: callEndRecordManager)
            viewModel.setNavigationRouter(router: navigationRouter)
            viewModel.navigateWithCallState(state: viewModel.callState)
        }
        .onDisappear {
            #if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = false
            #endif
            viewModel.setCallEndRecordManager(manager: nil)
            viewModel.setNavigationRouter(router: nil)
        }
    }
}
struct VideoCallMobileViewPreviewWrapper: View {
    @State private var callService = MockCallService(userAccount: UserAccount.testAccount)
    @StateObject private var callEndRecordManager = CallEndRecordManager()
    @StateObject private var navigationRouter = NavigationRouter()
    var body: some View {
        VideoCallMobileView(viewModel: VideoCallViewModel(callService: callService))
            .environmentObject(callEndRecordManager)
            .environmentObject(navigationRouter)
    }
}

#Preview {
    VideoCallMobileViewPreviewWrapper()
}
#endif
