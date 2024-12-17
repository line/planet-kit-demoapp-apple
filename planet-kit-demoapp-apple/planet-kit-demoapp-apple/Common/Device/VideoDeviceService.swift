import Combine

struct VideoCaptureDevice: Identifiable {
    let id: String
    let name: String
    let isUsed: Bool

    var used: VideoCaptureDevice {
        VideoCaptureDevice(id: id, name: name, isUsed: true)
    }

    var unused: VideoCaptureDevice {
        VideoCaptureDevice(id: id, name: name, isUsed: false)
    }
}

protocol VideoDeviceService {
    var onVideoDevices: AnyPublisher<[VideoCaptureDevice], Never> { get }
    var onDisconnected: AnyPublisher<VideoCaptureDevice, Never> { get }
    func select(captureDevice: VideoCaptureDevice)
}

class DeviceEnvironmentManager: ObservableObject {
    let audioDeviceService: AudioDeviceService
    let videoDeviceService: VideoDeviceService

    init(audioDeviceService: AudioDeviceService, videoDeviceService: VideoDeviceService) {
        self.audioDeviceService = audioDeviceService
        self.videoDeviceService = videoDeviceService
    }
}
