import SwiftUI

struct MakeCallView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel: MakeCallViewModel

    private let basicCallText = LocalizedString.lp_demoapp_1to1_scenarios_basic.string
    private let peerIdText = LocalizedString.lp_demoapp_1to1_scenarios_basic_setup_callee.string
    private let inputPeerIdText = LocalizedString.lp_demoapp_1to1_scenarios_basic_setup_placeholder.string
    private let inputPeerIdGuideText = LocalizedString.lp_demoapp_1to1_scenarios_basic_setup_guide.string

    private let audioCallText = LocalizedString.lp_demoapp_1to1_scenarios_basic_setup_btn1.string
    private let videoCallText = LocalizedString.lp_demoapp_1to1_scenarios_basic_setup_btn2.string

    init(settingsService: SettingsService, userAccount: UserAccount) {
        let callService = PlanetCallService(userAccount: userAccount)
        _viewModel = StateObject(wrappedValue: MakeCallViewModel(settingsService: settingsService, callService: callService))
    }

    init(viewModel: MakeCallViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var audioCallButton: some View {
        UseCaseButton(action: {
            viewModel.makeCall(useVideo: false)
        }, title: audioCallText, active: true)
        .buttonStyle(.plain)
    }

    private var videoCallButton: some View {
        UseCaseButton(action: {
            viewModel.makeCall(useVideo: true)
        }, title: videoCallText, active: true)
        .buttonStyle(.plain)
    }

    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    Text(peerIdText)
                        .font(DemoFont.default.weight(.bold))
                        .foregroundColor(Color.inputItemTitle)
                    Text("*")
                        .font(DemoFont.default.weight(.bold))
                        .foregroundColor(DemoColor.required)
                }
                .padding(.top, 5)

                TextField(inputPeerIdText, text: $viewModel.peerId)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.peerId) { _ in
                        viewModel.validatePeerId()
                    }
                    .padding(.top, 5)
                    #if os(iOS)
                    .autocapitalization(.none)
                    #endif

                Text(inputPeerIdGuideText)
                    .font(DemoFont.small)
                    .foregroundColor(DemoColor.gray500)
                    .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)

            VStack(alignment: .center, spacing: 20) {
                audioCallButton
                videoCallButton
            }
            .padding(.top, 10)

            Spacer()
        }
        .navigationTitle(Text(basicCallText))
        .navigationDestination(for: MakeCallViewDestination.self) { destination in
            buildView(destination: destination)
        }
        .navigationBarBackButtonHidden()
        .navigationItems(leading: BackNavigationBarItem(action: viewModel.navigateToBack), trailing: homeButton)
        .callStartFailureAlert(record: $viewModel.startRecord)
        .onAppear {
            viewModel.setNavigationRouter(router: navigationRouter)
        }
        .onDisappear {
            viewModel.setNavigationRouter(router: nil)
        }
    }

    private var homeButton: some View {
        Button(action: {
            viewModel.navigateToHome()
        }, label: {
            Image(systemName: "house")
                .font(.title3)
        })
        .buttonStyle(.plain)
    }

    @ViewBuilder private func buildView(destination: MakeCallViewDestination) -> some View {
        switch destination {
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

        default:
            EmptyView()
        }
    }
}

private extension View {
    func callStartFailureAlert(record: Binding<CallStartRecord?>) -> some View {
        modifier(CallStartFailureViewModifier(record: record))
    }
}

struct MakeCallView_Previews: PreviewProvider {
    static var defaultView: some View {
        ZStack {
            let settingsService = MockSettingsService()
            let userAccount = UserAccount.testAccount
            @StateObject var navigationRouter = NavigationRouter()
            MakeCallView(settingsService: settingsService, userAccount: userAccount)
                .environmentObject(navigationRouter)
        }
    }

    static var makeCallErrorView: some View {
        ZStack {
            let settingsService = MockSettingsService()
            let callService = MockCallService(userAccount: UserAccount.testAccount)
            @StateObject var navigationRouter = NavigationRouter()

            let viewModel = MakeCallViewModel(settingsService: settingsService, callService: callService)

            ZStack {
                MakeCallView(viewModel: viewModel)
                    .environmentObject(navigationRouter)
                    .onAppear {
                        viewModel.peerId = "100"
                        callService.reserveMakeCallError("MakeCall Error")
                        viewModel.makeCall(useVideo: false)
                    }
            }
        }
    }

    static var previews: some View {
        Group {
            Self.defaultView
            Self.makeCallErrorView
        }
    }
}
