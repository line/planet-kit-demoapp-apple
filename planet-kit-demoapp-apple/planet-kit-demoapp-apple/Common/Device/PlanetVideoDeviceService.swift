import PlanetKit
import Combine

class PlanetVideoDeviceService: VideoDeviceService {

    private var videoDevicesSubject = CurrentValueSubject<[VideoCaptureDevice], Never>([])
    private var disconnectionSubject = PassthroughSubject<VideoCaptureDevice, Never>()

    var onVideoDevices: AnyPublisher<[VideoCaptureDevice], Never> {
        videoDevicesSubject.eraseToAnyPublisher()
    }

    var onDisconnected: AnyPublisher<VideoCaptureDevice, Never> {
        disconnectionSubject.eraseToAnyPublisher()
    }

    init() {
        refreshDevices()
        PlanetKitCamera.shared.addDeviceChangeDelegate(self)
    }

    deinit {
        PlanetKitCamera.shared.removeDeviceChangeDelegate(self)
    }

    func select(captureDevice: VideoCaptureDevice) {
        guard let device = PlanetKitCamera.shared.devices.first(where: { $0.uniqueID == captureDevice.id }) else {
            return
        }
        PlanetKitCamera.shared.change(device: device)
    }

    private func refreshDevices() {
        var devices =
            PlanetKitCamera.shared.devices.compactMap { device in
                let isUsed = (PlanetKitCamera.shared.currentDevice?.uniqueID == device.uniqueID)
                return VideoCaptureDevice(id: device.uniqueID, name: device.name, isUsed: isUsed)
            }

        devices = devices.sortedVideoDevice()
        videoDevicesSubject.send(devices)
    }

    private func onAdded(_ device: PlanetKitVideoCaptureDevice) {
        var devices = videoDevicesSubject.value

        guard nil == devices.firstIndex(where: { $0.id == device.uniqueID }) else {
            return
        }

        let isUsed = (PlanetKitCamera.shared.currentDevice?.uniqueID == device.uniqueID)
        let captureDevice = VideoCaptureDevice(id: device.uniqueID, name: device.name, isUsed: isUsed)
        devices.append(captureDevice)
        devices = devices.sortedVideoDevice()

        videoDevicesSubject.send(devices)
    }

    private func onRemoved(_ device: PlanetKitVideoCaptureDevice) {
        var devices = videoDevicesSubject.value

        guard let index = devices.firstIndex(where: { $0.id == device.uniqueID }) else {
            return
        }
        let device = devices.remove(at: index)

        videoDevicesSubject.send(devices)
        disconnectionSubject.send(device)
    }

    private func onSelected(_ device: PlanetKitVideoCaptureDevice) {
        var devices = videoDevicesSubject.value

        while let lastUsedIndex = devices.firstIndex(where: { $0.isUsed }) {
            devices[lastUsedIndex] = devices[lastUsedIndex].unused
        }
        if let index = devices.firstIndex(where: { $0.id == device.uniqueID }) {
            devices[index] = VideoCaptureDevice(id: device.uniqueID, name: device.name, isUsed: true)
        }

        videoDevicesSubject.send(devices)
    }
}

extension PlanetVideoDeviceService: PlanetKitCameraDeviceChangeDelegate {
    func didCameraDeviceConnect(device: PlanetKitVideoCaptureDevice) {
        AppLog.v("#demo camera connected \(device.name) \(device.uniqueID)")
        DispatchQueue.main.async {
            self.onAdded(device)
        }
    }

    func didCameraDeviceDisconnect(device: PlanetKitVideoCaptureDevice) {
        AppLog.v("#demo camera disconnected \(device.name) \(device.uniqueID)")
        DispatchQueue.main.async {
            self.onRemoved(device)
        }
    }

    func didCameraDeviceSelect(device: PlanetKitVideoCaptureDevice, preset: PlanetKitCameraPreset) {
        AppLog.v("#demo camera selected \(device.name) \(device.uniqueID) \(preset)")
        DispatchQueue.main.async {
            self.onSelected(device)
        }
    }
}

private extension Array where Element == VideoCaptureDevice {
    mutating func sortedVideoDevice() -> [Element] {
        return sorted { lhs, rhs -> Bool in
            return lhs.id < rhs.id
        }
    }
}
