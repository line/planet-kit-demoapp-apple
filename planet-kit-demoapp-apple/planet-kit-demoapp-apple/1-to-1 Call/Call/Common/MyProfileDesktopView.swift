import SwiftUI

struct MyProfileDesktopView: View {

    @StateObject private var viewModel: CallViewModel

    init(viewModel: CallViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center) {
                ProfileNoImage(size: 84)

                ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
                    Text("")
                        .foregroundColor(DemoColor.textOnCall)
                }
                .padding(.top, 5)
                .overlay {
                    MyMuteIconView(isMuted: $viewModel.isMyAudioMuted)
                        .offset(CGSize(width: 0, height: 20.0))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            Spacer()
        }
        .cornerRadius(4)
        .overlay {
            if viewModel.isUserSpeaking {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(lineWidth: 2)
                    .foregroundColor(DemoColor.activeGreen)
            }
        }
    }
}
