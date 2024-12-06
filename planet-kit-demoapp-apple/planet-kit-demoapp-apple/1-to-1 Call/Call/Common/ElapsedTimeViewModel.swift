import SwiftUI
import Combine

class ElapsedTimeViewModel: ObservableObject {

    @Published var elapsedTime: String?

    let callService: any CallService
    private var timerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    init(callService: any CallService) {
        self.callService = callService

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.elapsedTime = callService.callDuration?.timeString
            }

        callService.onEvent
            .sink { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .onDisconnected:
                    timerCancellable?.cancel()
                default: ()
                }
            }
            .store(in: &cancellables)
    }
}
