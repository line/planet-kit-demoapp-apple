import PlanetKit

extension PlanetKitMediaType {
    var hasAudio: Bool { self == .audio || self == .audiovideo }
    var hasVideo: Bool { self == .video || self == .audiovideo }
}

extension PlanetKitVideoStatus {
    var isPausedOrDisabled: Bool { state == .paused || state == .disabled }
}

#if os(macOS)
import CoreAudio

extension PlanetKitAudioDevice {
    var isSystemDefaultSelected: Bool {
        var selector: AudioObjectPropertySelector
        if isCapturable {
            selector = kAudioHardwarePropertyDefaultInputDevice
        } else {
            selector = kAudioHardwarePropertyDefaultOutputDevice
        }

        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var defaultDeviceID = kAudioObjectUnknown
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &propertyAddress,
            0,
            nil,
            &propertySize,
            &defaultDeviceID
        )

        guard status == noErr else {
            AppLog.v("Error getting default audio device: \(status)")
            return false
        }
        return deviceID == defaultDeviceID
    }
}
#endif
