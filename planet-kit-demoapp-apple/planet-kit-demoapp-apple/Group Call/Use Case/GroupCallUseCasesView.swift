import SwiftUI

extension GroupCallUseCasesViewDestination: Identifiable { // Identifiable for List
    var id: String {
        switch self {
        case .basic:
            return LocalizedString.lp_demoapp_group_scenarios_basic.string
        case .socialAndCommunity:
            return LocalizedString.lp_demoapp_group_scenarios_social.string
        case .onlineEducation:
            return LocalizedString.lp_demoapp_group_scenarios_onlineedu.string
        case .remoteWork:
            return LocalizedString.lp_demoapp_group_scenarios_remotework.string
        case .gameAndMetaverse:
            return LocalizedString.lp_demoapp_group_scenarios_game.string
        case .back:
            return "Back"
        }
    }
}

struct GroupCallUseCasesView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel: GroupCallUseCasesViewModel

    init(settingsService: SettingsService) {
        _viewModel = StateObject(wrappedValue: GroupCallUseCasesViewModel(settingsService: settingsService))
    }

    private let navigationTitleText = LocalizedString.lp_demoapp_group_scenarios_title.string
    private let scenariosGuideText = LocalizedString.lp_demoapp_group_scenarios_guide.string

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

            Text(scenariosGuideText)
                .font(DemoFont.default)
                .foregroundColor(DemoColor.gray500)
                .padding()
        }
        .navigationTitle(navigationTitleText)
        .navigationDestination(for: GroupCallUseCasesViewDestination.self) { destination in
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
            viewModel.navigateTo(destination: .back)
        }, label: {
            Image(systemName: "house")
                .font(.title3)
        })
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func buildView(destination: GroupCallUseCasesViewDestination) -> some View {
        switch destination {
        case .basic:
            GroupCallJoinView(settingsService: viewModel.settingsService)
        default:
            EmptyView()
        }
    }
}

struct GroupCallUseCasesViewPreviewWrapper: View {
    @StateObject private var navigationRouter = NavigationRouter()
    @State private var settingsService = MockSettingsService()
    var body: some View {
        GroupCallUseCasesView(settingsService: settingsService)
            .environmentObject(navigationRouter)
    }
}

#Preview {
    GroupCallUseCasesViewPreviewWrapper()
}
