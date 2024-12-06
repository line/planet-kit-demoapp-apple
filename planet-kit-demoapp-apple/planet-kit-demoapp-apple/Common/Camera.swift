import Foundation
import PlanetKit

protocol Camera {
    func addStream(stream: any VideoStream)
    func removeStream(stream: any VideoStream)

    #if os(iOS)
    func switchCameraPosition()
    #endif
    func start()
    func stop()
}

class PlanetCamera: Camera {
    let camera: PlanetKitCamera = PlanetKitCamera.shared

    func addStream(stream: any VideoStream) {
        guard let stream = stream as? PlanetVideoStream else {
            return
        }
        camera.addReceiver(stream.videoStream)
    }

    func removeStream(stream: any VideoStream) {
        guard let stream = stream as? PlanetVideoStream else {
            return
        }

        camera.removeReceiver(stream.videoStream)
    }

    #if os(iOS)
    func switchCameraPosition() {
        camera.switchPosition()
    }
    #endif

    func start() {
        camera.open(device: nil)
        camera.start()
    }

    func stop() {
        camera.stop()
        camera.close()
    }

    func resetCurrentDevice() {
        #if os(iOS)
        let device = PlanetKitCamera.shared.devices.first(where: { $0.device.position == .front })
        #else
        let device: PlanetKitVideoCaptureDevice? = nil
        #endif
        camera.change(device: device)
    }
}
