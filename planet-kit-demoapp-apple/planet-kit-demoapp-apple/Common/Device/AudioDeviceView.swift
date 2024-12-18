import SwiftUI

#if os(macOS)
struct AudioDeviceView: View {

    @StateObject private var viewModel: AudioDeviceViewModel

    init(service: AudioDeviceService) {
        _viewModel = StateObject(wrappedValue: AudioDeviceViewModel(service: service))
    }

    var body: some View {
        List {
            Section {
                ForEach(viewModel.microphoneDevices) { device in
                    DeviceItemButton(action: {
                        viewModel.select(device: device)
                    }, title: device.displayName, active: device.isUsed, disabled: device.isUsed)
                }
            } header: {
                Text("Microphone").font(.subheadline)
            }

            Section {
                ForEach(viewModel.speakerDevices) { device in
                    DeviceItemButton(action: {
                        viewModel.select(device: device)
                    }, title: device.displayName, active: device.isUsed, disabled: device.isUsed)
                }
            } header: {
                Text("Speaker").font(.subheadline)
            }
        }
    }
}

struct AudioDeviceViewModifier: ViewModifier {

    @Binding var isShown: Bool
    let service: any AudioDeviceService
    let bottom: CGFloat

    init(isShown: Binding<Bool>, service: any AudioDeviceService, bottom: CGFloat = 35) {
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
                        AudioDeviceView(service: service)
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
        let service = MockAudioDeviceService()
        AudioDeviceView(service: service)
            .frame(width: 300)
    }
}
#endif
