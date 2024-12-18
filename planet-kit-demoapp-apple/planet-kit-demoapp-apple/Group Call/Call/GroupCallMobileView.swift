import SwiftUI
#if os(iOS)
import UIKit
#endif

struct GroupCallMobileView: View {
    @StateObject private var viewModel: GroupCallViewModel
    @StateObject private var toolBarViewModel: GroupCallToolBarViewModel
    @State private var toastMessages: [String] = []

    @EnvironmentObject var callEndRecordManager: CallEndRecordManager
    @EnvironmentObject var navigationRouter: NavigationRouter

    @Binding var startRecord: CallStartRecord?

    init(service: any GroupCallService, startRecord: Binding<CallStartRecord?>) {
        _viewModel = StateObject(wrappedValue: GroupCallViewModel(service: service))
        _startRecord = startRecord
        let control = GroupCallToolBarControl(groupCallService: service)
        _toolBarViewModel = StateObject(wrappedValue: GroupCallToolBarViewModel(control: control))
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                GeometryReader { geometry in
                    let itemHeight = (geometry.size.height / 3).rounded()
                    let itemCornerRadius = 10.0
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 5),
                        GridItem(.flexible(), spacing: 5)
                    ], spacing: 5) {
                        GroupCallMyView(userId: viewModel.myUserId,
                                        name: viewModel.myName, myMediaStatus: viewModel.service.myMediaStatus, myVideoStream: viewModel.service.myVideoStream)
                            .frame(height: itemHeight)
                            .cornerRadius(itemCornerRadius)

                        ForEach(viewModel.peers.prefix(5), id: \.id) { peer in
                            GroupCallPeerView(peer: peer)
                                .frame(height: itemHeight)
                                .cornerRadius(itemCornerRadius)
                        }

                        ForEach(0..<(6 - min(viewModel.peers.count + 1, 6)), id: \.self) { _ in
                            Color.clear
                                .frame(height: itemHeight)
                                .cornerRadius(itemCornerRadius)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                GroupCallToolBarMobileView(viewModel: toolBarViewModel)
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack(alignment: .leading) {
                Text("\(viewModel.roomId) (\(viewModel.participantCount))")
                Text("\(viewModel.duration)")
            }
            .foregroundColor(.white)
            .padding()
        }
        .onAppear {
            viewModel.setCallEndRecordManager(manager: callEndRecordManager)
            viewModel.setNavigationRouter(router: navigationRouter)
            viewModel.startGroupCall()
            #if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = true
            #endif
        }
        .onDisappear {
            viewModel.setCallEndRecordManager(manager: nil)
            viewModel.setNavigationRouter(router: nil)
            #if os(iOS)
            UIApplication.shared.isIdleTimerDisabled = false
            #endif
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(edges: .bottom)
        .background(.black)
        .toolbar(.hidden)
        .onChange(of: viewModel.disconnectedPeers) { _ in
            for disconnectedPeer in viewModel.disconnectedPeers {
                toastMessages.append(LocalizedString.lp_demoapp_group_scenarios_basic_inacall_toast(disconnectedPeer).string)
            }
            viewModel.clearDisconnectedPeers()
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
        .toastMessageListViewModifier(messages: $toastMessages)
    }
}

private extension View {
    func toastMessageListViewModifier(messages: Binding<[String]>) -> some View {
        modifier(ToastMessageListViewModifier(messages: messages, showOnTop: false))
    }
}

#Preview {
    GroupCallMobileViewPreviewWrapper()
}

struct GroupCallMobileViewPreviewWrapper: View {
    @State private var settingsService = MockSettingsService()
    @State private var startRecord: CallStartRecord?
    @StateObject private var callEndRecordManager = CallEndRecordManager()
    @StateObject private var deviceManager = DeviceEnvironmentManager(audioDeviceService: MockAudioDeviceService(), videoDeviceService: MockVideoDeviceService())
    @StateObject private var navigationRouter = NavigationRouter()

    var body: some View {
        VStack {
            GroupCallMobileView(service: MockGroupCallService(roomId: "test-room", videoPauseOnStart: true, muteOnStart: false, settingsService: settingsService), startRecord: $startRecord)
                .environmentObject(deviceManager)
                .environmentObject(navigationRouter)
                .environmentObject(callEndRecordManager)
        }
        .background(Color.black)
        .padding()
    }
}
