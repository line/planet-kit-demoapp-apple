import SwiftUI
#if os(iOS)
import UIKit
#endif

struct MainView: View {

    @StateObject private var viewModel: MainViewModel
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var callEndRecordManager = CallEndRecordManager()

    init(settingsService: SettingsService, deviceAuthService: DeviceAuthorizationService) {
        _viewModel = StateObject(wrappedValue: MainViewModel(settingsService: settingsService, deviceAuthService: deviceAuthService))

        #if os(iOS)
        // Disable animations applied to the NavigationStack
        // TODO: we will enable later if issue found.
        UINavigationBar.setAnimationsEnabled(false)
        #endif
    }

    private let callButtonText = LocalizedString.lp_demoapp_main_btn1.string
    private let groupCallText = LocalizedString.lp_demoapp_main_btn2.string
    private let warningMessage = LocalizedString.lp_demoapp_main_guide.string
    private let okText = LocalizedString.lp_demoapp_setting_popup3.string
    private let cameraAllowGuideText = LocalizedString.lp_demoapp_common_permission_noti2.string
    private let microphoneAllowGuideText = LocalizedString.lp_demoapp_common_permission_noti1.string

    private var settingsButton: some View {
        Button(action: {
            viewModel.navigateToSettings()
        }) {
            ZStack(alignment: .topTrailing) {
                SettingsImage(size: 20, redDot: !viewModel.isRegistered)
                    .frame(width: 20, height: 20)
            }
        }
        .buttonStyle(.plain)
    }

    private var logBrowserButton: some View {
        Button(action: {
            viewModel.navigateToLogBrowser()
        }) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 20))
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
    }

    private var callButton: some View {
        Button(action: {
            viewModel.navigateToCallUseCase()
        }, label: {}).buttonStyle(FilledButtonStyle(title: callButtonText, active: viewModel.isRegistered, width: 233, height: 56))
        .disabled(!viewModel.isRegistered)
    }

    private var conferenceButton: some View {
        Button(action: {
            viewModel.navigateToGroupCallUseCase()
        }, label: {}).buttonStyle(FilledButtonStyle(title: groupCallText, active: viewModel.isRegistered, width: 233, height: 56))
        .disabled(!viewModel.isRegistered)
    }

    private var versionLabel: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(viewModel.versionDescription)
                .font(DemoFont.default)
                .kerning(0.06)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
    }

    private var warningLabel: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(warningMessage)
                .font(
                    DemoFont.default
                        .weight(.bold)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(DemoColor.errorMessage)
                .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    var body: some View {
        ZStack {
            NavigationStack(path: $navigationRouter.path) {
                VStack {
                    callButton
                        .padding(.top, 84)

                    conferenceButton
                        .padding(.top, 29)

                    if !viewModel.isRegistered {
                        warningLabel
                            .padding(.top, 54)
                    }

                    Spacer()

                    versionLabel
                        .frame(alignment: .center)
                }
                .padding()
                .navigationTitle(viewModel.appName)
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .topBarTrailing) {
                        settingsButton
                    }
                    #elseif os(macOS)
                    ToolbarItem(placement: .automatic) {
                        settingsButton
                    }
                    #endif
                }
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .navigationSplitViewStyle(.balanced)
                .navigationDestination(for: MainViewDestination.self) { destination in
                    buildView(destination: destination)
                }
            }
        }
        #if os(macOS)
        .incomingCallAlert(incomingCallInfo: $viewModel.incomingCallInfo, action: { response in
            switch response {
            case .accept:
                viewModel.accept()
            case .decline:
                viewModel.decline()
            }
            
        })
        #endif
        .onAppear {
            AppEnvironmentManager.onMainViewAppear()
            viewModel.setCallEndRecordManager(manager: callEndRecordManager)
        }
        .onDisappear {
            viewModel.setCallEndRecordManager(manager: nil)
        }
        #if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
        viewModel.requestAccessForDevice()
        }
        .alert(Text(""), isPresented: $viewModel.isCameraUnauthorized) {
            Button(okText) {
                viewModel.openAppSettings(.microphone)
            }
        } message: {
            Text(cameraAllowGuideText)
        }
        #elseif os(macOS)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
        viewModel.requestAccessForDevice()
        }
        #endif
        .alert(Text(""), isPresented: $viewModel.isMicrophoneUnauthorized) {
            Button(okText) {
                viewModel.openAppSettings(.microphone)
            }
        } message: {
            Text(microphoneAllowGuideText)
        }
        .environmentObject(callEndRecordManager)
        .environmentObject(navigationRouter)
        .callEndStatusAlert(manager: callEndRecordManager)
        .onChange(of: viewModel.incomingCallInfo) { newInfo in
            // Close the end status alert when a new incoming call arrives.
            if newInfo != nil {
                viewModel.clearAllRecords()
            }
        }
        .onAppear {
            viewModel.setNavigationRouter(router: navigationRouter)
        }
        .onDisappear {
            viewModel.setNavigationRouter(router: nil)
        }
    }

    @ViewBuilder
    func buildView(destination: MainViewDestination) -> some View {
        switch destination {
        case .settings:
            SettingsView(service: viewModel.settingsService)
        case .logBrowser:
            LogBrowserView()
        case .callUseCase:
            CallUseCasesView(settingsService: viewModel.settingsService)
        case .groupCallUseCase:
            GroupCallUseCasesView(settingsService: viewModel.settingsService)
        case .audioCall(let callService as (any CallService)):
            #if os(iOS)
            AudioCallMobileView(callService: callService)
            #elseif os(macOS)
            AudioCallDesktopView(callService: callService)
            #endif
        case .videoCall(let callService as (any CallService)):
            #if os(iOS)
            VideoCallMobileView(callService: callService)
            #elseif os(macOS)
            VideoCallDesktopView(callService: callService)
            #endif
        case .previewCall(let callService as (any CallService)):
            #if os(iOS)
            EmptyView()
            #elseif os(macOS)
            PreviewCallDesktopView(callService: callService)
            #endif
        default:
            EmptyView()
        }
    }
}

private extension View {
    func incomingCallAlert(incomingCallInfo: Binding<IncomingCallInfo?>, action: @escaping (IncomingCallResponse) -> Void) -> some View {
        modifier(IncomingCallViewModifier(incomingCallInfo: incomingCallInfo, action: action))
    }

    func callEndStatusAlert(manager: CallEndRecordManager) -> some View {
        modifier(CallEndStatusListViewModifier(manager: manager))
    }
}

#Preview {
    MainView(settingsService: MockSettingsService(), deviceAuthService: MockDeviceAuthorizationService())
}

class CallEndRecordManager: ObservableObject {
    @Published var records: [CallEndRecord] = []
}

class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
}
