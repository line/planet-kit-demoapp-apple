#if os(macOS)
import SwiftUI
import Combine
import Foundation

struct GroupCallToolBarDesktopView: View {

    @ObservedObject var viewModel: GroupCallToolBarViewModel
    @EnvironmentObject var deviceEnvironmentManager: DeviceEnvironmentManager

    private let leaveButtonText = LocalizedString.lp_demoapp_group_scenarios_basic_inacall_btn.string

    var leavebutton: some View {
        Button(action: {
            viewModel.leaveGroupCall()
        }, label: {
            HStack(alignment: .center, spacing: 0) {
                Text(leaveButtonText)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        })
        .frame(width: 80, height: 40)
        .background(.red)
        .contentShape(.capsule)
        .cornerRadius(20)
        .buttonStyle(.borderless)
    }

    var toggleMuteButton: some View {
        Button(action: {
            viewModel.toggleMute()
        }) {
            if viewModel.isMuted {
                Image(systemName: "mic")
                    .font(DemoFont.normalButton)
                    .symbolVariant(.slash)
                    .foregroundStyle(.red, .white, .clear)
            } else {
                Image(systemName: "mic")
                    .font(DemoFont.normalButton)
                    .symbolVariant(.none)
                    .foregroundStyle(.white, .secondary, .tertiary)
            }
        }
        .frame(width: 50, height: 50)
        .buttonStyle(.plain)
    }

    var toggleVideoButton: some View {
        Button(action: {
            viewModel.toggleVideo()
        }) {
            if viewModel.isVideoPaused {
                Image(systemName: "video")
                    .font(DemoFont.normalButton)
                    .symbolVariant(.slash)
                    .foregroundStyle(.red, .white)
            } else {
                Image(systemName: "video")
                    .font(DemoFont.normalButton)
                    .symbolVariant(.none)
                    .foregroundColor(.white)
            }
        }
        .frame(width: 50, height: 50)
        .buttonStyle(.plain)
    }

    var audioDeviceButton: some View {
        Button(action: {
            viewModel.pickAudioDevice()
        }, label: {
            Image(systemName: "chevron.up")
                .font(DemoFont.normalButton)
                .symbolVariant(.fill.circle)
                .scaledToFit()
                .foregroundStyle(.white, .white, .tertiary)
        })
        .frame(width: 30, height: 30)
        .buttonStyle(.plain)
    }

    var videoDeviceButton: some View {
        Button(action: {
            viewModel.pickVideoDevice()
        }, label: {
            Image(systemName: "chevron.up")
                .font(DemoFont.normalButton)
                .symbolVariant(.fill.circle)
                .scaledToFit()
                .foregroundStyle(.white, .white, .tertiary)
        })
        .frame(width: 30, height: 30)
        .buttonStyle(.plain)
    }

    var participantCountIcon: some View {
        HStack {
            Image(systemName: "person")
                .font(.system(size: 20))
                .symbolVariant(.none)
                .foregroundColor(.white)
            Text("\(viewModel.participantCount)")
                .foregroundColor(.white)
        }
        .frame(width: 50, height: 32)
        .background(Color.clear)
        .cornerRadius(8)
    }

    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                Spacer()
                HStack(spacing: 0) {
                    toggleMuteButton
                    audioDeviceButton
                }
                HStack(spacing: 0) {
                    toggleVideoButton
                    videoDeviceButton
                }
                participantCountIcon
                Spacer()
            }
            HStack {
                Spacer()
                leavebutton
                    .padding(.vertical, 20)
                    .padding(.trailing, 10)
            }
        }
        .background(Color.black)
    }
}

#Preview {
    GroupCallToolBarDesktopViewPreviewWrapper()
}

struct GroupCallToolBarDesktopViewPreviewWrapper: View {
    private var control: GroupCallToolBarControl
    @StateObject private var deviceManager = DeviceEnvironmentManager(audioDeviceService: MockAudioDeviceService(), videoDeviceService: MockVideoDeviceService())
    @StateObject private var viewModel: GroupCallToolBarViewModel

    init() {
        let testService = MockGroupCallService(roomId: "test-roomId", videoPauseOnStart: true, muteOnStart: false, settingsService: MockSettingsService())
        let control = GroupCallToolBarControl(groupCallService: testService)
        self.control = control
        _viewModel = StateObject(wrappedValue: GroupCallToolBarViewModel(control: control))
    }

    var body: some View {
        VStack {
            GroupCallToolBarDesktopView(viewModel: viewModel)
                .environmentObject(deviceManager)
        }
        .padding()
    }
}
#endif
