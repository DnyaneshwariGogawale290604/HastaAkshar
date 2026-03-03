import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var dancersOffset: CGFloat = 400
    @State private var dancersOpacity: Double  = 0
    @State private var contentOpacity: Double  = 0

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        GeometryReader { geo in
            let dancerH = geo.size.height * (isIPad ? 0.50 : 0.48)

            ZStack(alignment: .bottom) {
                Image("dancers")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.95, alignment: .bottom)
                    .frame(maxHeight: dancerH)
                    .clipped()
                    .offset(y: dancersOffset)
                    .opacity(dancersOpacity)

                VStack(spacing: 0) {
                    Spacer()

                    Text("HastaAkshar")
                        .font(.system(isIPad ? .largeTitle : .title, design: .default).weight(.bold))
                        .foregroundColor(MudraTheme.crimsonRed)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)

                    Text("Learning the language of mudras")
                        .font(.system(isIPad ? .title3 : .callout, design: .default).weight(.medium))
                        .foregroundColor(MudraTheme.mutedGold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Spacer()
                    Spacer()

                    Text("Tap anywhere to begin")
                        .font(.system(.caption, design: .default))
                        .foregroundColor(MudraTheme.offBlack.opacity(0.40))
                        .padding(.bottom, dancerH + 16)
                }
                .frame(width: geo.size.width)
                .opacity(contentOpacity)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(
            ZStack {
                MudraTheme.cream
                Image("temple_template")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.25)
            }
            .ignoresSafeArea()
        )
        .contentShape(Rectangle())
        .onTapGesture { onFinish() }
        .onAppear {
            withAnimation(.easeIn(duration: 0.4)) {
                contentOpacity = 1
            }
            withAnimation(.spring(response: 0.75, dampingFraction: 0.72).delay(0.15)) {
                dancersOffset  = 0
                dancersOpacity = 1
            }
        }
    }
}
