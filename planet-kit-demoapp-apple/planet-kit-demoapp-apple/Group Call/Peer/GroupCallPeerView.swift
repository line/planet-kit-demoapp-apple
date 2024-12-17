import SwiftUI
import Combine

struct GroupCallPeerView: View {
    @StateObject private var viewModel: GroupCallPeerViewModel

    init(peer: any GroupCallPeer) {
        _viewModel = StateObject(wrappedValue: GroupCallPeerViewModel(peer: peer))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if viewModel.isVideoEnabled {
                VideoView(stream: viewModel.peer.videoStream)
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
        .onAppear {
            if viewModel.isVideoEnabled {
                viewModel.startVideo()
            }
        }
        .onChange(of: viewModel.isVideoEnabled) { newValue in
            if newValue {
                viewModel.startVideo()
            }
        }
    }
}

#Preview {
    GroupCallPeerPreviewWrapper()
}

struct GroupCallPeerPreviewWrapper: View {
    @State private var audioLevelInput: String = ""
    let testPeer = MockGroupCallPeer(id: "test", name: "test name", isConnected: true, isVideoEnabled: true, isMuted: false, averageAudioLevel: 0)

    var body: some View {
        VStack {
            GroupCallPeerView(peer: testPeer)
            HStack {
                Button("Mute") {
                    testPeer.mute(mute: true)
                }
                .background(Color.blue)
                .foregroundColor(.white)
                Spacer()

                Button("Unmute") {
                    testPeer.mute(mute: false)
                }
                .background(Color.blue)
                .foregroundColor(.white)
                Spacer()

                Button("Disconnect") {
                    testPeer.disconnect()
                }
                .background(Color.blue)
                .foregroundColor(.white)
                Spacer()

                Button("Set Audio Level") {
                    if let level = Int(audioLevelInput) {
                        testPeer.setVolumeLevel(level: level)
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
