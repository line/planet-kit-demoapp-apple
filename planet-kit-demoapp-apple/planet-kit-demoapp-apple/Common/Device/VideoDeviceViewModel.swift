import SwiftUI
import Combine

class VideoDeviceViewModel: ObservableObject {

    @Published var devices: [VideoCaptureDevice] = []

    private let service: VideoDeviceService
    private var cancellables = Set<AnyCancellable>()

    init(service: VideoDeviceService) {
        self.service = service

        service.onVideoDevices
            .sink { [weak self] devices in
                self?.updateDevices(devices)
            }
            .store(in: &cancellables)
    }

    private func updateDevices(_ devices: [VideoCaptureDevice]) {
        self.devices = devices
        AppLog.v("#demo video devices: \(devices.count) \(devices)")
    }

    func select(device: VideoCaptureDevice) {
        service.select(captureDevice: device)
    }
}
