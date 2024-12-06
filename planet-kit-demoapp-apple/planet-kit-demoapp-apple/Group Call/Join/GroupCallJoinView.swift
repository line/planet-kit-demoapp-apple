import SwiftUI

struct GroupCallJoinView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel: GroupCallJoinViewModel
    @State private var startRecord: CallStartRecord?

    private let errorToastTitle = LocalizedString.lp_demoapp_common_error_startfail0.string
    private let errorToastMessage = LocalizedString.lp_demoapp_common_error_startfail2.string
    private let errorToastButtonText = LocalizedString.lp_demoapp_setting_popup3.string

    private let roomNameText = LocalizedString.lp_demoapp_group_scenarios_setup_roomname.string
    private let roomNameGuideText = LocalizedString.lp_demoapp_group_scenarios_setup_roomnameguide.string

    // TODO: replace with xlt
    private let roomNamePlaceHolderText = "Input room name"

    private let setUpButtonText = LocalizedString.lp_demoapp_group_scenarios_setup_btn.string
    private let nativationTitleText = LocalizedString.lp_demoapp_group_scenarios_basic.string

    init(settingsService: SettingsService) {
        _viewModel = StateObject(wrappedValue: GroupCallJoinViewModel(settingsService: settingsService))
    }

    var body: some View {
        VStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    Text(roomNameText)
                        .font(DemoFont.default.weight(.bold))
                        .foregroundColor(Color.inputItemTitle)
                    Text("*")
                        .font(DemoFont.default.weight(.bold))
                        .foregroundColor(DemoColor.required)
                }
                .padding(.top, 5)

                TextField(roomNamePlaceHolderText, text: $viewModel.roomName)
                    .autocorrectionDisabled()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: viewModel.roomName) { _ in
                        viewModel.validateRoomName()
                    }
                    #if os(iOS)
                    .autocapitalization(.none)
                    #endif
                
                Text(roomNameGuideText)
                    .font(DemoFont.small)
                    .foregroundColor(DemoColor.gray500)
                    .padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 40)

            VStack(alignment: .center, spacing: 20) {
                UseCaseButton(action: {
                    viewModel.enterPreview()
                }, title: setUpButtonText, active: true)
                .buttonStyle(.plain)
            }
            .padding(.top, 10)

            Spacer()
        }
        .navigationTitle(Text(nativationTitleText))
        .navigationDestination(for: GroupCallJoinViewDestination.self) { destination in
            buildView(destination: destination)
        }
        .navigationBarBackButtonHidden()
        .navigationItems(leading: BackNavigationBarItem(action: {
            viewModel.navigateBack()
        }), trailing: homeButton)
        .toastViewModifier(showToast: $viewModel.showErrorToast, title: errorToastTitle, message: errorToastMessage, buttonText: errorToastButtonText)
        .callStartFailureAlert(record: $startRecord)
        .onAppear {
            viewModel.setNavigationRouter(router: navigationRouter)
        }
        .onDisappear {
            viewModel.setNavigationRouter(router: nil)
        }
    }

    private var homeButton: some View {
        return Button(action: {
            viewModel.navigateHome()
        }, label: {
            Image(systemName: "house")
                .font(.title3)
        })
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func buildView(destination: GroupCallJoinViewDestination) -> some View {
        switch destination {
        case .enterPreview(let roomName):
            #if os(iOS)
            GroupCallPreviewMobileView(roomName: roomName, previewService: PlanetCameraPreviewService(), settingsService: viewModel.settingsService, startRecord: $startRecord)
            #endif
            #if os(macOS)
            GroupCallPreviewDesktopView(roomName: roomName, previewService: PlanetCameraPreviewService(), settingsService: viewModel.settingsService, startRecord: $startRecord)
            #endif

        default:
            Text("error")
        }
    }
}

private extension View {
    func toastViewModifier(showToast: Binding<Bool>, title: String, message: String, buttonText: String) -> some View {
        modifier(ToastViewModifier(showToast: showToast, title: title, message: message, buttonText: buttonText))
    }
    func callStartFailureAlert(record: Binding<CallStartRecord?>) -> some View {
        modifier(CallStartFailureViewModifier(record: record))
    }
}

struct GroupCallJoinViewPreviewWrapper: View {
    @StateObject private var navigationRouter = NavigationRouter()
    @State private var settingsService = MockSettingsService()

    var body: some View {
        GroupCallJoinView(settingsService: settingsService)
            .environmentObject(navigationRouter)
    }
}

#Preview {
    GroupCallJoinViewPreviewWrapper()
}
