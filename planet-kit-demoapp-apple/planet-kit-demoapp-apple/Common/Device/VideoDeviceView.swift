import SwiftUI

struct VideoDeviceView: View {

    @StateObject private var viewModel: VideoDeviceViewModel

    init(service: VideoDeviceService) {
        _viewModel = StateObject(wrappedValue: VideoDeviceViewModel(service: service))
    }

    var body: some View {
        List {
            Section {
                ForEach(viewModel.devices) { device in
                    DeviceItemButton(action: {
                        viewModel.select(device: device)
                    }, title: device.name, active: device.isUsed, disabled: device.isUsed)
                }
            } header: {
                Text("Camera").font(.subheadline)
            }
        }
    }
}

struct VideoDeviceViewModifier: ViewModifier {

    @Binding var isShown: Bool
    let service: any VideoDeviceService
    let bottom: CGFloat

    init(isShown: Binding<Bool>, service: any VideoDeviceService, bottom: CGFloat) {
        _isShown = isShown
        self.service = service
        self.bottom = bottom
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if isShown {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isShown = false
                        }
                    VStack {
                        Spacer()
                        VideoDeviceView(service: service)
                            .frame(width: 300, height: 300)
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .inset(by: 0.5)
                                    .stroke(DemoColor.activeGreen, lineWidth: 1)
                            )
                    }
                    .padding(.bottom, bottom)
                }
            }
    }
}

#Preview {
    ZStack {
        let service = MockVideoDeviceService()
        VideoDeviceView(service: service)
            .onAppear {
                service.selected(id: "test_id")
            }
    }
}
