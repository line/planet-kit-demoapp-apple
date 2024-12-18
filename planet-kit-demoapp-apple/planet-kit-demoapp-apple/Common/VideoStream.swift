import Foundation
import PlanetKit

protocol VideoStream {
    func addView(view: VideoView.UIViewType)
    func removeView(view: VideoView.UIViewType)
}

class PlanetVideoStream: VideoStream {
    let videoStream: PlanetKitVideoStream = PlanetKitVideoStream()

    func addView(view: VideoView.UIViewType) {
        videoStream.addReceiver(view)
    }

    func removeView(view: VideoView.UIViewType) {
        videoStream.removeReceiver(view)
    }
}

extension PlanetVideoStream: PlanetKitVideoOutputDelegate {
    func videoOutput(_ videoBuffer: PlanetKitVideoBuffer) {
        videoStream.videoOutput(videoBuffer)
    }
}
