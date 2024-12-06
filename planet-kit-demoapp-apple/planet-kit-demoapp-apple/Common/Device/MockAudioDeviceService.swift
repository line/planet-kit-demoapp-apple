import Combine

class MockAudioDeviceService: AudioDeviceService {

    private var audioDevicesSubject = CurrentValueSubject<[AudioDevice], Never>([])
    private var audioDevices: [AudioDevice] { audioDevicesSubject.value }

    var onAudioDevices: AnyPublisher<[AudioDevice], Never> {
        audioDevicesSubject.eraseToAnyPublisher()
    }

    init() {
        let devices = [
            AudioDevice(uid: "default_mic_id", name: "Default Mic Name", type: .systemDefaultMicrophone, isUsed: true),
            AudioDevice(uid: "test_mic_id", name: "Test Mic Name", type: .microphone, isUsed: false),
            AudioDevice(uid: "default_spk_id", name: "Default Spk Name", type: .systemDefaultSpeaker, isUsed: true),
            AudioDevice(uid: "test_spk_id", name: "Test Spk Name", type: .speaker, isUsed: false)
        ]
        audioDevicesSubject.send(devices)
    }

    func select(device: AudioDevice) {
        guard let index = audioDevices.firstIndex(where: { $0.id == device.id && $0.type == device.type }) else {
            return
        }

        var devices = audioDevicesSubject.value

        let device = audioDevices[index]
        let newDevice = AudioDevice(uid: device.id, name: device.name, type: device.type, isUsed: true)
        devices[index] = newDevice

        audioDevicesSubject.send(devices)
    }
}
