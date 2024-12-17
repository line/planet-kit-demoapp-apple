import Foundation

protocol CameraPreviewService {
    var stream: any VideoStream { get }
    var camera: any Camera { get }

    func start()
    func stop()
    #if os(iOS)
    func switchCameraPosition()
    #endif

}

class PlanetCameraPreviewService: CameraPreviewService {
    #if os(iOS)
    func switchCameraPosition() {
        camera.switchCameraPosition()
    }
    #endif

    let stream: VideoStream = PlanetVideoStream()
    let camera: Camera = PlanetCamera()

    func start() {
        camera.addStream(stream: stream)
        camera.start()
    }

    func stop() {
        camera.removeStream(stream: stream)
        camera.stop()
    }
}
