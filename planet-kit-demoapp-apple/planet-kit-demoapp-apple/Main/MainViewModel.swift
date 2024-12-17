import SwiftUI
import Combine

enum MainViewDestination: Hashable {
    case settings
    case logBrowser // TOBEDEL: after release
    case callUseCase
    case groupCallUseCase
    case audioCall(Any)
    case videoCall(Any)
    case previewCall(Any)

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.settings, .settings),
             (.callUseCase, .callUseCase),
             (.groupCallUseCase, .groupCallUseCase):
            return true
        case let (.audioCall(lhsType), .audioCall(rhsType)),
             let (.videoCall(lhsType), .videoCall(rhsType)),
             let (.previewCall(lhsType), .previewCall(rhsType)):
            guard let l = lhsType as? (any CallService),
                  let r = rhsType as? (any CallService) else {
                return false
            }
            return l.hashValue == r.hashValue
        default: return false
        }
    }
}

class MainViewModel: ObservableObject {
    @Published var isRegistered = false
    @Published var isMicrophoneUnauthorized = false
    @Published var isCameraUnauthorized = false
    var navigationRouter: NavigationRouter?

    var settingsService: SettingsService
    let deviceAuthService: any DeviceAuthorizationService
    private var callEndRecordManager: CallEndRecordManager?

    private var cancellables = Set<AnyCancellable>()

    @Published var incomingCallInfo: IncomingCallInfo?
    private var incomingCallService: (any CallService)?

    var versionDescription: String {
        let appVersion = LocalizedString.lp_demoapp_main_versioninfo1(AppEnvironmentManager.appVersion).string
        let sdkVersion = LocalizedString.lp_demoapp_main_versioninfo2(AppEnvironmentManager.sdkVersion).string
        return "\(appVersion)\n\(sdkVersion)"
    }
    var appName: String { AppEnvironmentManager.appName }

    init(settingsService: SettingsService, deviceAuthService: any DeviceAuthorizationService) {
        self.settingsService = settingsService
        self.deviceAuthService = deviceAuthService

        AppLog.v("#demoapp version - app: \(AppEnvironmentManager.appVersion) sdk: \(AppEnvironmentManager.sdkVersion)")

        isRegistered = settingsService.isRegistrationValid

        settingsService.onUserAccountUpdate
            .sink { [weak self] _ in
                self?.isRegistered = settingsService.isRegistrationValid
            }
            .store(in: &cancellables)

        settingsService.onPush
            .sink { [weak self] message in
                self?.onPush(message: message)
            }
            .store(in: &cancellables)
    }

    func navigateToSettings() {
        if !settingsService.isRegistrationValid {
            settingsService.reset()
        }

        navigationRouter?.path.append(MainViewDestination.settings)
    }

    func navigateToCallUseCase() {
        guard settingsService.isRegistrationValid else {
            settingsService.reset()
            return
        }

        navigationRouter?.path.append(MainViewDestination.callUseCase)
    }

    func navigateToGroupCallUseCase() {
        guard settingsService.isRegistrationValid else {
            settingsService.reset()
            return
        }

        navigationRouter?.path.append(MainViewDestination.groupCallUseCase)
    }

    func navigateToAudioCall(callService: any CallService) {
        navigationRouter?.path.append(MainViewDestination.audioCall(callService))
    }

    func navigateToVideoCall(callService: any CallService) {
        navigationRouter?.path.append(MainViewDestination.videoCall(callService))
    }

    func navigateToPreviewCall(callService: any CallService) {
        navigationRouter?.path.append(MainViewDestination.previewCall(callService))
    }

    private func alertIncomingCall(callService: any CallService) {
        incomingCallInfo = IncomingCallInfo(isVideoCall: callService.isVideoCall, callerName: callService.peerId)
        incomingCallService = callService
        AppLog.v("#demo alertIncomingCall")
    }

    private func bindCallState(callService: any CallService, connected: @escaping () -> Void, disconnected: @escaping () -> Void) {
        var isConnected = false
        var cancellable: AnyCancellable?
        cancellable = callService.callState
            .sink { [weak self] callState in
                switch callState {
                case .connected:
                    connected()
                    isConnected = true
                case .disconnected(let reason):
                    if !isConnected {
                        self?.callEndRecordManager?.records.append(CallEndRecord(callType: .oneToOneCall(callService.peerId), disconnectReason: reason))
                    }
                    disconnected()
                    cancellable?.cancel()
                default: break
                }
            }
    }

    func setCallEndRecordManager(manager: CallEndRecordManager?) {
        callEndRecordManager = manager
    }

    func clearAllRecords() {
        callEndRecordManager?.records.removeAll()
    }

    func requestAccessForDevice() {
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            isMicrophoneUnauthorized = !(await deviceAuthService.requestAccess(for: .microphone))
            isCameraUnauthorized = !(await deviceAuthService.requestAccess(for: .camera))
        }
    }

    func openAppSettings(_ type: DeviceAuthorizationType) {
        deviceAuthService.openAppSettings(for: type)
    }
}

extension MainViewModel {

    private func onPush(message: PushMessage) {
        AppLog.v("##demoapp incoming call \(message)")

        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            guard let userAccount = settingsService.userAccount else {
                // TODO: CallKit handle for VoIP push payload
                AppLog.v("##demoapp critical error : userAccount should be valid!")
                return
            }

            let callService = PlanetCallService(userAccount: userAccount)
            callService.registerCallKit()

            // Push message is paused while calling verifyCall().
            settingsService.isPushPaused = true

            let result = await callService.verifyCall(message: message)
            guard result == .success else {
                settingsService.isPushPaused = false
                return
            }

            guard incomingCallInfo == nil, incomingCallService == nil else {
                callService.declineCall()
                settingsService.isPushPaused = false
                return
            }
            alertIncomingCall(callService: callService)

            #if os(macOS)
            if callService.isVideoCall {
                navigateToPreviewCall(callService: callService)
            }
            #endif

            bindCallState(callService: callService, connected: { [weak self] in
                guard let `self` = self else { return }
                #if os(iOS)
                if callService.isVideoCall {
                    navigateToVideoCall(callService: callService)
                } else {
                    navigateToAudioCall(callService: callService)
                }
                #endif
                incomingCallInfo = nil
                incomingCallService = nil
            }, disconnected: { [weak self] in
                guard let `self` = self else { return }
                incomingCallInfo = nil
                incomingCallService = nil
                settingsService.isPushPaused = false
            })
        }
    }

    func navigateToLogBrowser() {
        navigationRouter?.path.append(MainViewDestination.logBrowser)
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }
}

// MARK: for incoming call view in macOS
#if os(macOS)
extension MainViewModel {
    func accept() {
        defer {
            incomingCallService = nil
            incomingCallInfo = nil
        }

        guard let callService = incomingCallService else {
            return
        }

        callService.acceptCall()

        if callService.isVideoCall == true {
            navigateToVideoCall(callService: callService)
        } else {
            navigateToAudioCall(callService: callService)
        }
    }

    func decline() {
        defer {
            incomingCallService = nil
            incomingCallInfo = nil
        }

        guard let callService = incomingCallService else {
            return
        }

        callService.declineCall()
    }
}
#endif
