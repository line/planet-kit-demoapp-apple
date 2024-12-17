import SwiftUI
import Combine
import Foundation

struct GroupCallToolBarMobileView: View {

    @ObservedObject var viewModel: GroupCallToolBarViewModel
    private let leaveButtonText = LocalizedString.lp_demoapp_group_scenarios_basic_inacall_btn.string

    var leavebutton: some View {
        Button(action: {
            viewModel.leaveGroupCall()
        }, label: {
            HStack(alignment: .center, spacing: 0) {
                Text(leaveButtonText)
                    .font(.system(size: 16).bold())
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
        .contentShape(.circle)
        .buttonStyle(.borderless)
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
        .contentShape(.circle)
        .buttonStyle(.borderless)
    }

    var switchCameraButton: some View {
        Button(action: {
            viewModel.switchCamera()
        }, label: {
            Image(systemName: "arrow.triangle.2.circlepath.camera")
                .font(DemoFont.normalButton)
                .foregroundColor(.white)
        })
        .frame(width: 50, height: 50)
        .buttonStyle(.borderless)
    }

    var body: some View {
        HStack {
            leavebutton
                .padding(.vertical, 20)
                .padding(.leading, 10)
            Spacer()
            toggleMuteButton
            Spacer()
            toggleVideoButton
            Spacer()
            switchCameraButton
                .padding(.trailing, 10)
        }
        .background(Color.black)
    }
}

#Preview {
    GroupCallToolbarMobileViewPreviewWrapper()
}

struct GroupCallToolbarMobileViewPreviewWrapper: View {
    private var control: GroupCallToolBarControl
    @StateObject private var viewModel: GroupCallToolBarViewModel

    init() {
        let testService = MockGroupCallService(roomId: "test-roomId", videoPauseOnStart: true, muteOnStart: false, settingsService: MockSettingsService())
        let control = GroupCallToolBarControl(groupCallService: testService)
        self.control = control
        _viewModel = StateObject(wrappedValue: GroupCallToolBarViewModel(control: control))
    }

    var body: some View {
        VStack {
            GroupCallToolBarMobileView(viewModel: viewModel)
        }
        .padding()
    }
}
