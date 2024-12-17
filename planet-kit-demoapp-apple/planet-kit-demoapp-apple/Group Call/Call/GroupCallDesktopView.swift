#if os(macOS)
import SwiftUI

struct GroupCallDesktopView: View {
    @StateObject private var viewModel: GroupCallViewModel
    @StateObject private var toolBarViewModel: GroupCallToolBarViewModel
    @State private var toastMessages: [String] = []

    @EnvironmentObject var callEndRecordManager: CallEndRecordManager
    @EnvironmentObject var deviceEnvironmentManager: DeviceEnvironmentManager
    @EnvironmentObject var navigationRouter: NavigationRouter

    @Binding var startRecord: CallStartRecord?

    init(service: any GroupCallService, startRecord: Binding<CallStartRecord?>) {
        _viewModel = StateObject(wrappedValue: GroupCallViewModel(service: service))
        let control = GroupCallToolBarControl(groupCallService: service)
        _toolBarViewModel = StateObject(wrappedValue: GroupCallToolBarViewModel(control: control))
        _startRecord = startRecord
    }

    private let okText = LocalizedString.lp_demoapp_setting_popup3.string
    private let cameraAllowGuideText = LocalizedString.lp_demoapp_common_permission_noti2.string

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let itemHeight = (geometry.size.height / 2).rounded()
                let itemCornerRadius = 10.0
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 5),
                    GridItem(.flexible(), spacing: 5),
                    GridItem(.flexible(), spacing: 5)
                ], spacing: 5) {
                    if viewModel.callState == .connected {
                        GroupCallMyView(userId: viewModel.myUserId,
                                        name: viewModel.myName, myMediaStatus: viewModel.service.myMediaStatus, myVideoStream: viewModel.service.myVideoStream)
                            .frame(height: itemHeight)
                            .cornerRadius(itemCornerRadius)

                        ForEach(viewModel.peers, id: \.id) { peer in
                            GroupCallPeerView(peer: peer)
                                .frame(height: itemHeight)
                                .cornerRadius(itemCornerRadius)
                        }
                    }
                }
            }
            .padding(.top, 50)

            GroupCallToolBarDesktopView(viewModel: toolBarViewModel)
        }
        .onChange(of: viewModel.disconnectedPeers) { _ in
            for disconnectedPeer in viewModel.disconnectedPeers {
                toastMessages.append(LocalizedString.lp_demoapp_group_scenarios_basic_inacall_toast(disconnectedPeer).string)
            }
            viewModel.clearDisconnectedPeers()
        }
        .navigationTitle("\(viewModel.roomId) (\(viewModel.duration))")
        .onAppear {
            viewModel.setCallEndRecordManager(manager: callEndRecordManager)
            viewModel.setNavigationRouter(router: navigationRouter)
            viewModel.startGroupCall()
            viewModel.bindVideoDeviceService(deviceEnvironmentManager.videoDeviceService)
        }
        .onDisappear {
            viewModel.setCallEndRecordManager(manager: nil)
            viewModel.setNavigationRouter(router: nil)
        }
        .onChange(of: viewModel.callState) { newState in
            switch newState {
            case .startFailed(let reason):
                // TODO: remove binding to inject record to view model on onAppear
                startRecord = CallStartRecord(callType: .groupCall(viewModel.roomId), startFailReason: reason)
            default:
                break
            }

            viewModel.navigateWithCallState(callState: newState)
        }
        .audioDevicePopup(isShown: $toolBarViewModel.isAudioDevicePopup, service: deviceEnvironmentManager.audioDeviceService)
        .videoDevicePopup(isShown: $toolBarViewModel.isVideoDevicePopup, service: deviceEnvironmentManager.videoDeviceService)
        .toastMessageListViewModifier(messages: $toastMessages)
        .alert(Text(""), isPresented: $viewModel.isCameraUnauthorized) {
            Button(okText) {
                viewModel.openAppSettingsForCamera()
            }
        } message: {
            Text(cameraAllowGuideText)
        }
        .background(.black)
    }
}

private extension View {
    func toastMessageListViewModifier(messages: Binding<[String]>) -> some View {
        modifier(ToastMessageListViewModifier(messages: messages, showOnTop: true))
    }

    func audioDevicePopup(isShown: Binding<Bool>, service: AudioDeviceService) -> some View {
        modifier(AudioDeviceViewModifier(isShown: isShown, service: service, bottom: 50))
    }

    func videoDevicePopup(isShown: Binding<Bool>, service: VideoDeviceService) -> some View {
        modifier(VideoDeviceViewModifier(isShown: isShown, service: service, bottom: 50))
    }
}

#Preview {
    GroupCallDesktopViewPreviewWrapper()
}

struct GroupCallDesktopViewPreviewWrapper: View {
    @State private var startRecord: CallStartRecord?
    @State private var settingsService = MockSettingsService()

    @StateObject private var callEndRecordManager = CallEndRecordManager()
    @StateObject private var deviceManager = DeviceEnvironmentManager(audioDeviceService: MockAudioDeviceService(), videoDeviceService: MockVideoDeviceService())
    @StateObject private var navigationRouter = NavigationRouter()

    var body: some View {
        GroupCallDesktopView(service: MockGroupCallService(roomId: "test-room", videoPauseOnStart: true, muteOnStart: false, settingsService: settingsService), startRecord: $startRecord)
            .background(Color.black)
            .environmentObject(deviceManager)
            .environmentObject(navigationRouter)
            .environmentObject(callEndRecordManager)
    }
}
#endif
