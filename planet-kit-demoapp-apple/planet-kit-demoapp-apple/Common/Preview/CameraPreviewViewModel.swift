import Foundation

class CameraPreviewViewViewModel: ObservableObject {
    var stream: VideoStream {
        service.stream
    }

    private let service: CameraPreviewService

    init(service: CameraPreviewService) {
        self.service = service
    }

    func start() {
        service.start()
    }

    func stop() {
        service.stop()
    }
}
