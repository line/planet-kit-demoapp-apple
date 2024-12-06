import SwiftUI

extension CallUseCasesViewDestination: Identifiable {
    var id: String {
        switch self {
        case .basicCall:
            return LocalizedString.lp_demoapp_1to1_scenarios_basic.string
        case .expertConsultation:
            return LocalizedString.lp_demoapp_1to1_scenarios_expert.string
        case .dating:
            return LocalizedString.lp_demoapp_1to1_scenarios_dating.string
        case .mobilityDelivery:
            return LocalizedString.lp_demoapp_1to1_scenarios_mobility.string
        case .back:
            return "Back"
        case .home:
            return "Home"
        }
    }
}

struct CallUseCasesView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel: CallUseCasesViewModel

    init(settingsService: SettingsService) {
        _viewModel = StateObject(wrappedValue: CallUseCasesViewModel(settingsService: settingsService))
    }

    private let titleText = LocalizedString.lp_demoapp_main_btn1.string
    private let scenarioGuideText = LocalizedString.lp_demoapp_group_scenarios_guide.string

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ForEach(viewModel.destinations) { destination in
                HStack {
                    Spacer()
                    UseCaseButton(action: {
                        viewModel.navigateTo(destination: destination)
                    }, title: destination.id, active: viewModel.availableDestinations.contains(destination))
                    Spacer()
                }
            }
            Text(scenarioGuideText)
                .font(DemoFont.default)
                .foregroundColor(DemoColor.gray500)
                .padding()
        }
        .navigationTitle(Text(titleText))
        .navigationDestination(for: CallUseCasesViewDestination.self) { destination in
            buildView(destination: destination)
        }
        .navigationBarBackButtonHidden()
        .navigationItems(leading: BackNavigationBarItem(action: {
            viewModel.navigateTo(destination: .back)
        }), trailing: homeButton)
        .onAppear {
            viewModel.setNavigationRouter(router: navigationRouter)
        }
        .onDisappear {
            viewModel.setNavigationRouter(router: nil)
        }
    }

    private var homeButton: some View {
        return Button(action: {
            viewModel.navigateTo(destination: .home)
        }, label: {
            Image(systemName: "house")
                .font(.title3)
        })
        .buttonStyle(.plain)
    }

    @ViewBuilder private func buildView(destination: CallUseCasesViewDestination) -> some View {
        switch destination {
        case .basicCall:
            if let userAccount = viewModel.settingsService.userAccount {
                MakeCallView(settingsService: viewModel.settingsService, userAccount: userAccount)
            } else {
                Text("Invalid user account")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
            }
        default:
            EmptyView()
        }
    }
}

struct CallUseCasesViewPreviewWrapper: View {
    @State private var settingsService = MockSettingsService()
    @StateObject private var navigationRouter = NavigationRouter()

    var body: some View {
        CallUseCasesView(settingsService: settingsService)
            .environmentObject(navigationRouter)
    }
}

#Preview {
    CallUseCasesViewPreviewWrapper()
}
