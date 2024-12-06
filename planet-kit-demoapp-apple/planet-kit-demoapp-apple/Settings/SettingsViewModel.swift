import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    @Published var name  = ""
    @Published var userId  = ""
    @Published var expirationDate: Date?
    @Published var isRegistered = false
    var navigationRouter: NavigationRouter?

    @Published var isRegistering = false
    @Published var saveErrorMessage: String?

    private var canRegister: Bool {
        if name.count > 0, userId.count > 0 {
            return true
        } else {
            return false
        }
    }

    enum Error {
        case registerFailed
    }

    private let errorSubject = PassthroughSubject<Error, Never>()
    var onError: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()
    private let service: SettingsService

    init(service: SettingsService) {
        self.service = service

        if let userAccount = service.userAccount {
            name = userAccount.displayName ?? ""
            userId = userAccount.userId
            expirationDate = userAccount.expirationDate
            isRegistered = service.isRegistrationValid
        }

        service.onUserAccountUpdate
            .sink { [weak self] userAccount in
                self?.name = userAccount?.displayName ?? ""
                self?.userId = userAccount?.userId ?? ""
                self?.expirationDate = userAccount?.expirationDate
                self?.isRegistered = service.isRegistrationValid == true
            }
            .store(in: &cancellables)
    }

    func validateName() {
        if name.count > 10 {
            name = name.truncated(maxLength: 10)
        }
    }

    func validateUserId() {
        func isUserIdFormatValidvalid(userId: String) -> Bool {
            let regex = "^[a-zA-Z0-9-_]*$"
            return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: userId)
        }

        while userId.count > 0, !isUserIdFormatValidvalid(userId: userId) || userId.utf8.count > 64 {
            _ = userId.popLast()
        }
    }

    func register() {
        Task { @MainActor [weak self] in
            guard let `self` = self else { return }
            defer {
                isRegistering = false
            }
            isRegistering = true

            guard canRegister else {
                saveErrorMessage = LocalizedString.lp_demoapp_setting_error_savefail.string
                return
            }

            let result = await service.registerUser(name: name, userId: userId)

            switch result {
            case .success:
                errorSubject.send(.registerFailed)

            case .failure(let error):
                switch error {
                case .userIdExist:
                    saveErrorMessage = LocalizedString.lp_demoapp_setting_popup2.string
                case .unknown:
                    saveErrorMessage = "Unknown internal error"
                }
            }
        }
    }

    func reset() {
        service.reset()
    }

    func cancel() {
        navigationRouter?.path.removeLast()
    }

    func setNavigationRouter(router: NavigationRouter?) {
        navigationRouter = router
    }
}

extension String {
    func truncated(maxLength: Int) -> String {
        if count > maxLength {
            let endIndex = index(startIndex, offsetBy: maxLength)
            return String(self[..<endIndex])
        } else {
            return self
        }
    }
}
