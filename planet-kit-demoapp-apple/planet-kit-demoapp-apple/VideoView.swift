import SwiftUI
import PlanetKit

#if os(macOS)
private typealias UIViewRepresentable = NSViewRepresentable
#endif

struct VideoView: UIViewRepresentable {
    typealias UIViewType = PlanetKitMTKView

    #if os(macOS)
    let contentMode: PlanetKitUIViewContentMode
    #elseif os(iOS)
    let contentMode: UIView.ContentMode
    #endif
    @Binding var videoStream: PlanetKitVideoStream?

    var onDrawFirstFrame: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.onDrawFirstFrame = onDrawFirstFrame
        coordinator.videoStream = videoStream
        return coordinator
    }

    #if os(macOS)
    func makeNSView(context: Context) -> UIViewType {
        let mtkView = createView()
        mtkView.drawDelegate = context.coordinator
        return mtkView
    }

    func updateNSView(_ view: UIViewType, context: Context) {
    }

    static func dismantleNSView(_ view: UIViewType, coordinator: Coordinator) {
        coordinator.videoStream?.removeReceiver(view)
    }
    #elseif os(iOS)
    func makeUIView(context: Context) -> UIViewType {
        let mtkView = createView()
        mtkView.drawDelegate = context.coordinator
        return mtkView
    }

    func updateUIView(_ view: UIViewType, context: Context) {
    }

    static func dismantleUIView(_ view: UIViewType, coordinator: Coordinator) {
        coordinator.videoStream?.removeReceiver(view)
    }
    #endif

    // MARK: Internal Coordinator class
    class Coordinator {
        var onDrawFirstFrame: (() -> Void)?
        var videoStream: PlanetKitVideoStream?
    }
}

extension VideoView {
    private func createView() -> PlanetKitMTKView {
        let mtkView = PlanetKitMTKView(frame: .zero, device: nil)
        mtkView.contentMode = contentMode

        videoStream?.addReceiver(mtkView)

        return mtkView
    }
}

extension VideoView.Coordinator: PlanetKitMTKViewDelegate {
    func didDrawFirstFrame(_ view: PlanetKitMTKView) {
        onDrawFirstFrame?()
    }
}
