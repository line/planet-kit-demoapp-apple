import Combine

enum AudioDeviceType: String {
    case systemDefaultMicrophone
    case systemDefaultSpeaker
    case microphone
    case speaker

    var isMicrophone: Bool {
        switch self {
        case .systemDefaultMicrophone, .microphone: return true
        case .systemDefaultSpeaker, .speaker: return false
        }
    }

    var isSpeaker: Bool {
        !isMicrophone
    }
}

struct AudioDevice: Identifiable {
    let id: String
    let uid: String
    let name: String
    let type: AudioDeviceType
    let isUsed: Bool

    var isSystemDefault: Bool {
        switch type {
        case .systemDefaultMicrophone, .systemDefaultSpeaker:
            return true
        default:
            return false
        }
    }

    var displayName: String {
        isSystemDefault ? LocalizedString.lp_demoapp_common_systemsetting.string: name
    }

    init(uid: String, name: String, type: AudioDeviceType, isUsed: Bool) {
        switch type {
        case .systemDefaultMicrophone:
            id = "planet.systemDefaultMicrophone"
        case .systemDefaultSpeaker:
            id = "planet.systemDefaultSpeaker"
        case .microphone:
            id = uid
        case .speaker:
            id = uid
        }
        self.uid = uid
        self.name = name
        self.type = type
        self.isUsed = isUsed
    }

    var used: AudioDevice {
        AudioDevice(uid: uid, name: name, type: type, isUsed: true)
    }

    var unused: AudioDevice {
        AudioDevice(uid: uid, name: name, type: type, isUsed: false)
    }

    func setSystemDefaulted(_ defaulted: Bool) -> AudioDevice {
        AudioDevice(uid: uid, name: name, type: type, isUsed: isUsed)
    }
}

protocol AudioDeviceService {
    var onAudioDevices: AnyPublisher<[AudioDevice], Never> { get }
    func select(device: AudioDevice)
}
