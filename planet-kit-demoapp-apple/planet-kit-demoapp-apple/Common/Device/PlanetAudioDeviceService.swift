import Combine
import PlanetKit

#if os(macOS)
private extension PlanetKitAudioDevice {
    var type: AudioDeviceType? {
        if isCapturable {
            return .microphone
        } else if isPlayable {
            return .speaker
        } else {
            return nil
        }
    }
}

private extension Array where Element == AudioDevice {
    func sortedAudioDevice() -> [Element] {
        return sorted {
            if $0.isSystemDefault != $1.isSystemDefault {
                return $0.isSystemDefault
            }
            return $0.uid < $1.uid
        }
    }
}

class PlanetAudioDeviceService: AudioDeviceService {

    private var audioDevicesSubject = CurrentValueSubject<[AudioDevice], Never>([])
    private var isUseSystemSettingsMicrophone: Bool = true
    private var isUseSystemSettingsSpeaker: Bool = true

    var onAudioDevices: AnyPublisher<[AudioDevice], Never> {
        audioDevicesSubject.eraseToAnyPublisher()
    }

    init() {
        refreshDevices()
        PlanetKitAudio.shared.addDeviceChangeDelegate(self)
    }

    deinit {
        PlanetKitAudio.shared.removeDeviceChangeDelegate(self)
    }

    func select(device: AudioDevice) {
        guard let kitDevice = PlanetKitAudio.shared.devices?.first(where: { $0.uid == device.uid }) else {
            AppLog.v("#demo no audio device \(device.id) \(device.name)")
            return
        }
        AppLog.v("#dev select \(device.type) \(device.isUsed) \(device.uid)")

        var kitDeviceUnchanged = false
        if device.type.isMicrophone {
            if kitDevice.uid == PlanetKitAudio.shared.micDevice?.uid {
                kitDeviceUnchanged = true
            }
            PlanetKitAudio.shared.micDevice = kitDevice
            isUseSystemSettingsMicrophone = device.isSystemDefault
        } else {
            if kitDevice.uid == PlanetKitAudio.shared.spkDevice?.uid {
                kitDeviceUnchanged = true
            }
            PlanetKitAudio.shared.spkDevice = kitDevice
            isUseSystemSettingsSpeaker = device.isSystemDefault
        }

        if kitDeviceUnchanged {
            refreshDevices()
        } else {
            if PlanetKitAudio.default.isStarted {
                AppLog.v("#dev restart \(device.type) \(device.isUsed) \(device.uid)")
                PlanetKitAudio.default.stop()
                PlanetKitAudio.default.start()
            } else {
                refreshDevices()
            }
        }
    }

    private func restart(_ kitDevice: PlanetKitAudioDevice, device: AudioDevice) {
        guard kitDevice.uid == device.uid else {
            AppLog.v("#dev restart invalid uid - \(kitDevice.uid ?? "nil"), \(device.type) \(device.isUsed) \(device.uid)")
            return
        }

        if device.type.isMicrophone {
            PlanetKitAudio.shared.micDevice = kitDevice
        } else {
            PlanetKitAudio.shared.spkDevice = kitDevice
        }
        if PlanetKitAudio.default.isStarted {
            AppLog.v("#dev restart \(device.type) \(device.isUsed) \(device.uid)")
            PlanetKitAudio.default.stop()
            PlanetKitAudio.default.start()
        }
    }

    private func refreshDevices() {
        let kitDevices = PlanetKitAudio.shared.devices

        var newDevices = [AudioDevice]()
        kitDevices?.forEach { kitDevice in
            guard !kitDevice.isAggregateType else { return }
            guard let uid = kitDevice.uid, let name = kitDevice.name, let type = kitDevice.type else {
                return
            }

            let isUsed: Bool
            let isUsedInSystem: Bool
            if type.isMicrophone {
                isUsed = (PlanetKitAudio.shared.micDevice?.uid == uid)
                isUsedInSystem = isUseSystemSettingsMicrophone
            } else {
                isUsed = (PlanetKitAudio.shared.spkDevice?.uid == uid)
                isUsedInSystem = isUseSystemSettingsSpeaker
            }

            if kitDevice.isSystemDefaultSelected {
                if type.isMicrophone {
                    let device = AudioDevice(uid: uid, name: name, type: .systemDefaultMicrophone, isUsed: isUsedInSystem)
                    newDevices.append(device)
                    AppLog.v("#dev add \(device.type) \(device.isUsed) \(device.uid)")
                } else {
                    let device = AudioDevice(uid: uid, name: name, type: .systemDefaultSpeaker, isUsed: isUsedInSystem)
                    newDevices.append(device)
                    AppLog.v("#dev add \(device.type) \(device.isUsed) \(device.uid)")
                }
            }

            let device = AudioDevice(uid: uid, name: name, type: type, isUsed: !isUsedInSystem && isUsed)
            newDevices.append(device)
            AppLog.v("#dev add \(device.type) \(device.isUsed) \(device.uid)")
        }

        let sortedDevices = newDevices.sortedAudioDevice()
        audioDevicesSubject.send(sortedDevices)
    }

    private func updateDevice(_ kitDevice: PlanetKitAudioDevice, isUsed: Bool?) -> AudioDevice? {
        guard let uid = kitDevice.uid, let name = kitDevice.name, let type = kitDevice.type else {
            return nil
        }

        var existingDevices = audioDevicesSubject.value

        func updateAt(index: Int, type: AudioDeviceType) -> AudioDevice {
            let isUsedNew = (isUsed != nil ? isUsed!: existingDevices[index].isUsed)
            let device = AudioDevice(uid: uid, name: name, type: type, isUsed: isUsedNew)
            existingDevices[index] = device

            AppLog.v("#dev update \(device.type) \(device.isUsed) \(device.uid)")

            let sortedDevices = existingDevices.sortedAudioDevice()
            audioDevicesSubject.send(sortedDevices)
            return device
        }

        var targetType: AudioDeviceType
        if type.isMicrophone {
            targetType = isUseSystemSettingsMicrophone ? .systemDefaultMicrophone: .microphone
        } else {
            targetType = isUseSystemSettingsSpeaker ? .systemDefaultSpeaker: .speaker
        }

        if targetType == .systemDefaultMicrophone || targetType == .systemDefaultSpeaker {
            if let index = existingDevices.firstIndex(where: { $0.type == targetType }) {
                return updateAt(index: index, type: targetType)
            }
        } else {
            if let index = existingDevices.firstIndex(where: { $0.uid == kitDevice.uid && $0.type == type }) {
                return updateAt(index: index, type: type)
            }
        }
        AppLog.v("#dev no_update \(kitDevice.uid ?? "nil") \(type)")
        return nil
    }

    private func findDevices(type: AudioDeviceType, isUsed: Bool) -> [AudioDevice] {
        let devices = audioDevicesSubject.value
        return devices.compactMap { device -> AudioDevice? in
            return (device.type == type && device.isUsed == isUsed) ? device: nil
        }
    }

    private func updateExistingDevicesAsUnused(type: AudioDeviceType) {
        var existingDevices = audioDevicesSubject.value

        let usedDevices = findDevices(type: type, isUsed: true)
        guard !usedDevices.isEmpty else {
            return
        }
        usedDevices.forEach { usedDevice in
            if let index = existingDevices.firstIndex(where: { $0.uid == usedDevice.uid && $0.type == type }) {
                let device = usedDevice.unused
                existingDevices[index] = device
                AppLog.v("#dev updateExisting \(device.type) \(device.isUsed) \(device.uid)")
            }
        }

        let sortedDevices = existingDevices.sortedAudioDevice()
        audioDevicesSubject.send(sortedDevices)
    }

    private var currentMicrophone: AudioDevice? {
        let existingDevices = audioDevicesSubject.value
        return existingDevices.first(where: { $0.isUsed && $0.type.isMicrophone })
    }

    private var currentSpeaker: AudioDevice? {
        let existingDevices = audioDevicesSubject.value
        return existingDevices.first(where: { $0.isUsed && $0.type.isSpeaker })
    }
}

extension PlanetAudioDeviceService: PlanetKitAudioDeviceChangeDelegate {
    func didAudioDevicesUpdate(devices: [PlanetKitAudioDevice]) {
        DispatchQueue.main.async { [weak self] in
            self?.refreshDevices()
        }
    }

    func didAudioDeviceChange(device: PlanetKitAudioDevice?, type: PlanetKitAudioDeviceType) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            let previousDevice: AudioDevice?
            switch type {
            case .mic:
                previousDevice = currentMicrophone
            case .spk:
                previousDevice = currentSpeaker
            }

            if let kitDevice = device {
                let updatedDevice = updateDevice(kitDevice, isUsed: nil)
                if let updatedDevice = updatedDevice, previousDevice?.uid != updatedDevice.uid {
                    if PlanetKitAudio.default.isStarted {
                        AppLog.v("#dev restart \(type) \(updatedDevice.uid)")
                        PlanetKitAudio.default.stop()
                        PlanetKitAudio.default.start()
                    }
                }
            }
            refreshDevices()
        }
    }

    func didAudioDefaultSystemDeviceChange(device: PlanetKitAudioDevice?, type: PlanetKitAudioDeviceType) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if let kitDevice = device {
                AppLog.v("#dev default changed to \(kitDevice.name ?? "nil")")
                let device = updateDevice(kitDevice, isUsed: nil)
                if let device = device, device.isSystemDefault, device.isUsed {
                    restart(kitDevice, device: device)
                }
            } else {
                // The device was disconnected and left unused.
                AppLog.v("#dev default disconnected")
                switch type {
                case .mic:
                    updateExistingDevicesAsUnused(type: .systemDefaultMicrophone)
                case .spk:
                    updateExistingDevicesAsUnused(type: .systemDefaultSpeaker)
                }
            }
        }
    }

    func didAudioDeviceDataSourceChange(device: PlanetKitAudioDevice, dataSource: UInt32) {
        DispatchQueue.main.async { [weak self] in
            _ = self?.updateDevice(device, isUsed: nil)
        }
    }
}
#endif
