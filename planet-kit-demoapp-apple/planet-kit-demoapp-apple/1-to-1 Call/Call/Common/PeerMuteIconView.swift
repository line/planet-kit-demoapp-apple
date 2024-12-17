import SwiftUI

struct PeerMuteIconView: View {

    @Binding var isMuted: Bool

    var body: some View {
        if isMuted {
            Image(systemName: "mic")
                .font(.system(size: 16))
                .symbolVariant(.slash)
                .foregroundStyle(.red, .white, .clear)
        } else {
            Image(systemName: "mic")
                .font(.system(size: 16))
                .symbolVariant(.none)
                .foregroundStyle(.white, .secondary, .tertiary)
                .hidden()
        }
    }
}

#Preview {
    ZStack {
        @State var isMuted = true
        PeerMuteIconView(isMuted: $isMuted)
    }
}
