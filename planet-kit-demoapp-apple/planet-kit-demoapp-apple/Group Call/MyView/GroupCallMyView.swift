import SwiftUI
import Combine

struct GroupCallMyView: View {
    @StateObject private var viewModel: GroupCallMyViewViewModel

    init(userId: String, name: String, myMediaStatus: any MyMediaStatusObservable, myVideoStream: any VideoStream) {
        _viewModel = StateObject(wrappedValue: GroupCallMyViewViewModel(userId: userId, name: name, myMediaStatus: myMediaStatus, myVideoStream: myVideoStream))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if !viewModel.isVideoPaused {
                VideoView(stream: viewModel.myVideoStream)
            } else {
                ZStack {
                    Color.black
                    Image(systemName: "video")
                        .font(.system(size: 50))
                        .symbolVariant(.slash)
                        .foregroundStyle(.red, .white)
                }
            }

            #if os(macOS)
            GroupCallInfoDesktopView(name: viewModel.name, isMuted: viewModel.isMuted)
            #else
            GroupCallInfoMobileView(name: viewModel.name, isMuted: viewModel.isMuted)
            #endif
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(viewModel.isSpeaking ? Color.green : Color.clear, lineWidth: 2))
    }
}

#Preview {
    GroupCallMyViewWrapper()
}

struct GroupCallMyViewWrapper: View {
    @State private var audioLevelInput: String = ""
    private var groupCallService: MockGroupCallService
    private var settingsService: MockSettingsService

    init() {
        settingsService = MockSettingsService()
        let groupCallService = MockGroupCallService(roomId: "test-room", videoPauseOnStart: true, muteOnStart: false, settingsService: settingsService)
        self.groupCallService = groupCallService
    }

    var body: some View {
        VStack {
            GroupCallMyView(userId: settingsService.userAccount?.userId ?? "error", name: settingsService.userAccount?.displayName ?? "error", myMediaStatus: groupCallService.myMediaStatus, myVideoStream: groupCallService.myVideoStream)
            HStack {
                Button("Mute") {
                    groupCallService.muteMyAudio(mute: true)
                }
                .background(Color.blue)
                .foregroundColor(.white)
                Spacer()

                Button("Unmute") {
                    groupCallService.muteMyAudio(mute: false)
                }
                .background(Color.blue)
                .foregroundColor(.white)
                Spacer()

                Button("video resume") {
                    groupCallService.resumeMyVideo()
                }
                .background(Color.blue)
                .foregroundColor(.white)
                Spacer()

                Button("video pause") {
                    groupCallService.pauseMyVideo()
                }
                .background(Color.blue)
                .foregroundColor(.white)
                Spacer()

                Button("Set Audio Level") {
                    if let level = Int(audioLevelInput) {
                        groupCallService.testAverageAudioLevel(level: level)
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                Spacer()
            }

            TextField("Audio Level", text: $audioLevelInput)
                .padding()
                .background(Color(.gray))
                .cornerRadius(8)
        }
        .background(.black)
        .padding()
    }
}
