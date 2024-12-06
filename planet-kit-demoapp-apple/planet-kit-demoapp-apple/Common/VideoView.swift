import SwiftUI
import PlanetKit

class VideoViewModel: ObservableObject {
    let stream: any VideoStream

    init(stream: any VideoStream) {
        self.stream = stream
    }

    func addView(view: VideoView.UIViewType) {
        stream.addView(view: view)
    }

    func removeView(view: VideoView.UIViewType) {
        stream.removeView(view: view)
    }
}

#if os(macOS)
private typealias UIViewRepresentable = NSViewRepresentable
#endif

struct VideoView: UIViewRepresentable {
    typealias UIViewType = PlanetKitMTKView

    #if os(macOS)
    typealias VideoViewContentMode = PlanetKitUIViewContentMode
    #elseif os(iOS)
    typealias VideoViewContentMode = UIView.ContentMode
    #endif

    @StateObject private var viewModel: VideoViewModel

    private let contentMode: VideoViewContentMode
    private var onDrawFirstFrame: (() -> Void)?

    init(stream: any VideoStream, contentMode: VideoViewContentMode = .scaleAspectFill, onDrawFirstFrame: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: VideoViewModel(stream: stream))
        self.contentMode = contentMode
        self.onDrawFirstFrame = onDrawFirstFrame
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator(viewModel: viewModel)
        coordinator.onDrawFirstFrame = onDrawFirstFrame
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
        coordinator.viewModel.removeView(view: view)
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
        coordinator.viewModel.removeView(view: view)
    }
    #endif

    // MARK: Internal Coordinator class
    class Coordinator {
        var viewModel: VideoViewModel
        var onDrawFirstFrame: (() -> Void)?
        init(viewModel: VideoViewModel, onDrawFirstFrame: ( () -> Void)? = nil) {
            self.viewModel = viewModel
            self.onDrawFirstFrame = onDrawFirstFrame
        }
    }
}

extension VideoView {
    private func createView() -> PlanetKitMTKView {
        let mtkView = PlanetKitMTKView(frame: .zero, device: nil)
        mtkView.contentMode = contentMode
        viewModel.addView(view: mtkView)
        return mtkView
    }
}

extension VideoView.Coordinator: PlanetKitMTKViewDelegate {
    func didDrawFirstFrame(_ view: PlanetKitMTKView) {
        onDrawFirstFrame?()
    }
}

#Preview {
    VideoViewPreviewWrapper()
}

private struct VideoViewPreviewWrapper: View {
    @StateObject private var viewModel: CameraPreviewViewViewModel
    init() {
        _viewModel = StateObject(wrappedValue: CameraPreviewViewViewModel(service: PlanetCameraPreviewService()))
    }

    var body: some View {
        VStack {
            VideoView(stream: viewModel.stream)
            HStack {
                Button(action: {
                    viewModel.start()
                }) {
                    Text("start")
                }
                .buttonStyle(.borderless)
                Button(action: {
                    viewModel.stop()
                }) {
                    Text("stop")
                }
                .buttonStyle(.borderless)
            }
        }
        .background(Color.black)
        .padding()
    }
}
