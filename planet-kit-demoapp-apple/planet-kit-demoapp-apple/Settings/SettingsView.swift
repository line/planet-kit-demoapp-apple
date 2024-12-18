import SwiftUI
import Foundation

struct ResetButtonStyle: ButtonStyle {
    let title: String
    let active: Bool
    let width: CGFloat?
    let height: CGFloat?

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 0) { // EN / Text / L 17 / Bold
            Text(title)
                .font(DemoFont.buttons)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .frame(width: width, height: height, alignment: .center)
        .background(DemoColor.errorMessage)
        .cornerRadius(5)
    }
}

struct SettingsView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel: SettingsViewModel
    @State private var showResetAlert = false

    private let settingPopupTitleText = LocalizedString.lp_demoapp_setting_popup5.string
    private let settingPopupMessagetext = LocalizedString.lp_demoapp_setting_popup6.string
    private let settingPopupConfirmText = LocalizedString.lp_demoapp_setting_popup3.string
    private let settingPopipCancelText = LocalizedString.lp_demoapp_setting_popup4.string

    init(service: SettingsService) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(service: service))
    }

    private let settingTitleText = LocalizedString.lp_demoapp_setting_title.string
    private let saveText = LocalizedString.lp_demoapp_setting_btn1.string
    private let resetText = LocalizedString.lp_demoapp_setting_btn2.string

    private var profileImageView: some View {
        ProfileNoImage(size: 62)
    }

    @ViewBuilder
    private var nameTextFieldView: some View {
        let title = LocalizedString.lp_demoapp_setting_name.string
        let placeHolder = LocalizedString.lp_demoapp_setting_placeholder1.string
        let description = LocalizedString.lp_demoapp_setting_guide1.string

        SettingsTextFieldView(title: title,
                              placeHolder: placeHolder,
                              description: description,
                              disabled: viewModel.isRegistered,
                              text: $viewModel.name,
                              onChange: { _ in
                                  viewModel.validateName()
                              })
    }

    @ViewBuilder
    private var userIdTextFieldView: some View {
        let title = LocalizedString.lp_demoapp_setting_myuserid.string
        let placeHolder = LocalizedString.lp_demoapp_setting_placeholder2.string
        let description = LocalizedString.lp_demoapp_setting_guide2.string

        SettingsTextFieldView(title: title,
                              placeHolder: placeHolder,
                              description: description,
                              disabled: viewModel.isRegistered,
                              text: $viewModel.userId,
                              onChange: { _ in
                                  viewModel.validateUserId()
                              })
    }

    private var saveButton: some View {
        Button(action: {
            viewModel.register()
        }, label: {}).buttonStyle(FilledButtonStyle(title: saveText, active: true, width: 348, height: 46))
        .frame(height: 56)
        .disabled(viewModel.isRegistering)
    }

    private var expirationDateText: some View {
        Text(LocalizedString.lp_demoapp_setting_guide4(
            formatDateString(date: viewModel.expirationDate),
            formatGmtString(date: viewModel.expirationDate)
        ).string)
        .font(DemoFont.small)
        .foregroundColor(DemoColor.errorMessage)
    }

    private var resetButton: some View {
        Button(action: {
            showResetAlert = true
        }, label: {}).buttonStyle(ResetButtonStyle(title: resetText, active: true, width: 348, height: 46))
        .frame(height: 56)

    }

    var body: some View {
        ZStack {
            VStack(spacing: 5) {
                profileImageView
                    .padding(.top, 30)

                nameTextFieldView
                    .padding(.top, 15)

                userIdTextFieldView
                    .padding(.top, 10)

                if viewModel.isRegistered {
                    expirationDateText
                        .padding(.top, 10)
                    resetButton
                        .padding(.top, 5)
                } else {
                    saveButton
                        .padding(.top, 10)
                }

                Spacer()
            }
            .disabled(viewModel.isRegistering)

            if viewModel.isRegistering {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(2)
            }
        }
        .padding(.horizontal, 14)
        .navigationTitle(Text(settingTitleText))
        .navigationBarBackButtonHidden()
        .navigationItems(leading: BackNavigationBarItem(action: {
            viewModel.cancel()
        }).disabled(viewModel.isRegistering))
        .settingErrorAlert(description: $viewModel.saveErrorMessage)
        .alert(Text(settingPopupTitleText), isPresented: $showResetAlert) {
            Button(settingPopupConfirmText) {
                viewModel.reset()
            }
            Button(settingPopipCancelText, role: .cancel) {
                showResetAlert = false
            }
        } message: {
            Text(settingPopupMessagetext)
        }
        .onAppear {
            viewModel.setNavigationRouter(router: navigationRouter)
        }
        .onDisappear {
            viewModel.setNavigationRouter(router: nil)
        }
    }

    private func formatDateString(date: Date?) -> String {
        guard let date = date else {
            return "error"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    private func formatGmtString(date: Date?) -> String {
        guard let date = date else {
            return "error"
        }
        let dateFormatter = DateFormatter()
        let timeZoneAbbreviation = dateFormatter.timeZone.abbreviation() ?? ""
        let secondsFromGMT = dateFormatter.timeZone.secondsFromGMT(for: date)
        let hours = secondsFromGMT / 3600
        let minutes = abs(secondsFromGMT % 3600 / 60)
        let timeZoneOffset = String(format: "GMT%+02d:%02d", hours, minutes)
        return "(\(timeZoneAbbreviation) \(timeZoneOffset))"
    }
}

private extension View {
    func settingErrorAlert(description: Binding<String?>) -> some View {
        modifier(SettingsErrorViewModifier(description: description))
    }
}

#Preview {
    SettingsViewPreviewWrapper()
}

struct SettingsViewPreviewWrapper: View {
    @StateObject private var navigationRouter = NavigationRouter()
    @State private var service = MockSettingsService()

    var body: some View {
        VStack {
            SettingsView(service: service)
                .environmentObject(navigationRouter)
            VStack {
                Button("getAccessToken") {
                    Task {
                        await service.getAccessToken()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .disabled(!service.isRegistrationValid)
                .padding()
                Spacer()
            }
        }
        .padding()
    }
}
