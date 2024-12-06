import Combine

class MockVideoDeviceService: VideoDeviceService {

    private var videoDevicesSubject = CurrentValueSubject<[VideoCaptureDevice], Never>([])
    private var disconnectionSubject = PassthroughSubject<VideoCaptureDevice, Never>()

    var onVideoDevices: AnyPublisher<[VideoCaptureDevice], Never> {
        videoDevicesSubject.eraseToAnyPublisher()
    }

    var onDisconnected: AnyPublisher<VideoCaptureDevice, Never> {
        disconnectionSubject.eraseToAnyPublisher()
    }

    init() {
        let devices = [
            VideoCaptureDevice(id: "device_id", name: "Default Name", isUsed: true),
            VideoCaptureDevice(id: "test_id", name: "Test Name", isUsed: false)
        ]
        videoDevicesSubject.send(devices)
    }

    func select(captureDevice: VideoCaptureDevice) {
        var devices = videoDevicesSubject.value

        guard let index = devices.firstIndex(where: { $0.id == captureDevice.id }) else {
            return
        }

        if let lastUsedIndex = devices.firstIndex(where: { $0.isUsed }) {
            devices[lastUsedIndex] = devices[lastUsedIndex].unused
        }
        devices[index] = captureDevice.used

        videoDevicesSubject.send(devices)
    }
}

// MARK: Mock control API
extension MockVideoDeviceService {
    func selected(id: String) {
        let devices = videoDevicesSubject.value

        guard let index = devices.firstIndex(where: { $0.id == id }) else {
            return
        }
        select(captureDevice: devices[index])
    }
}
