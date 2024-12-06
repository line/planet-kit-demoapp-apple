import SwiftUI

struct GroupCallInfoDesktopView: View {
    let name: String
    let isMuted: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                if isMuted {
                    Image(systemName: "mic")
                        .font(.system(size: 12))
                        .symbolVariant(.slash)
                        .foregroundStyle(.red, .white, .clear)
                        .padding(.leading, 2)
                }

                Text(name)
                    .font(.system(size: 12))
                    .padding(5)
                    .foregroundColor(.white)
            }
            .background(Color.black.opacity(0.5))
            .padding(.trailing, 10)
        }
    }
}

struct GroupCallInfoMobileView: View {
    let name: String
    let isMuted: Bool

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding()
            Spacer()

            if isMuted {
                Image(systemName: "mic")
                    .frame(width: 30, height: 30)
                    .symbolVariant(.slash)
                    .foregroundStyle(.red, .white, .tertiary)
            }
        }
    }
}

#Preview {
    GroupCallInfoDesktopView(name: "test", isMuted: false)
    //    GroupCallInfoMobileView(name: "test", isMuted: true)
}
