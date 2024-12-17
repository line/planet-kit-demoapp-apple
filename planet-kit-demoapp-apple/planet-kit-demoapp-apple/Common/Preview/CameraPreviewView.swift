import SwiftUI

struct CameraPreviewView: View {
    @StateObject private var viewModel: CameraPreviewViewViewModel

    init() {
        _viewModel = StateObject(wrappedValue: CameraPreviewViewViewModel(service: PlanetCameraPreviewService()))
    }

    var body: some View {
        VStack {
            VideoView(stream: viewModel.stream)
                .onAppear {
                    viewModel.start()
                }
                .onDisappear {
                    viewModel.stop()
                }
        }
    }
}

#Preview {
    CameraPreviewView()
}

#if os(iOS)
extension UIWindowScene {
    static var firstSceneOrientation: UIInterfaceOrientation? {
        if #available(iOS 15, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?
                .interfaceOrientation
        } else {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        }
    }
}
#endif
