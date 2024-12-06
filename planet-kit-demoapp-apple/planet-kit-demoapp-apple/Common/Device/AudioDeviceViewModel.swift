import SwiftUI
import Combine

#if os(macOS)
class AudioDeviceViewModel: ObservableObject {

    @Published var microphoneDevices: [AudioDevice] = []
    @Published var speakerDevices: [AudioDevice] = []

    private let service: AudioDeviceService
    private var cancellables = Set<AnyCancellable>()

    init(service: AudioDeviceService) {
        self.service = service

        service.onAudioDevices
            .sink { [weak self] devices in
                self?.updateDevices(devices)
            }
            .store(in: &cancellables)
    }

    private func updateDevices(_ devices: [AudioDevice]) {
        microphoneDevices = devices.filter { $0.type.isMicrophone }
        AppLog.v("#demo mic: \(microphoneDevices.count) \(microphoneDevices)")
        speakerDevices = devices.filter { $0.type.isSpeaker }
        AppLog.v("#demo spk: \(speakerDevices.count) \(speakerDevices)")
    }

    func select(device: AudioDevice) {
        service.select(device: device)
    }
}
#endif
