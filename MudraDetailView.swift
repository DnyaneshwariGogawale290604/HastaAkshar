import SwiftUI


@MainActor private var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}


struct MudraDetailView: View {
    let mudra: Mudra
    @EnvironmentObject var progressStore: ProgressStore
    @Environment(\.dismiss) var dismiss

    @State private var showPractice = false
    @State private var exitToGrid   = false

    private var heroHeight: CGFloat { isIPad ? 360 : 240 }
    private var hPad: CGFloat       { isIPad ? 32 : 20 }

    var body: some View {
        ZStack(alignment: .bottom) {
            MudraTheme.cream.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection
                    infoSection
                    Spacer(minLength: 100)
                }
            }

            practiceButton
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: exitToGrid) { didExit in
            if didExit { dismiss() }
        }
        .navigationDestination(isPresented: $showPractice) {
            ARPracticeView(
                mudra:        mudra,
                onExitToGrid: { exitToGrid = true }
            )
            .environmentObject(progressStore)
        }
    }

   
    private var heroSection: some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if UIImage(named: mudra.illustrationAssetName) != nil {
                    Image(mudra.illustrationAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: heroHeight - 40)
                        .padding(.horizontal, 20)
                } else {
                    Image(systemName: "hand.raised")
                        .resizable()
                        .scaledToFit()
                        .frame(width: isIPad ? 160 : 100, height: isIPad ? 200 : 130)
                        .foregroundColor(MudraTheme.altaRed.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: heroHeight)
            .background(Color.white.opacity(0.80))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)

         
            if progressStore.completedMudraIds.contains(mudra.id) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12))
                    Text("Mastered")
                        .font(MudraTheme.captionFont)
                }
                .foregroundColor(MudraTheme.altaRed)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(MudraTheme.altaRed.opacity(0.1)))
                .padding([.top, .trailing], 12)
            }
        }
        .padding(.horizontal, hPad)
        .padding(.top, 16)
    }

    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("\(mudra.name) Mudra")
                .font(.system(isIPad ? .title : .title2, design: .default).weight(.semibold))
                .foregroundColor(MudraTheme.offBlack)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text(mudra.sanskritName)
                .font(MudraTheme.sanskritFont)
                .foregroundColor(MudraTheme.mutedGold)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, -10)

            InfoFloatCard(icon: "hand.raised.fill", tint: MudraTheme.altaRed) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Formation")
                        .font(.system(.caption, design: .default).weight(.semibold))
                        .foregroundColor(MudraTheme.altaRed)
                    Text(mudra.shortDescription)
                        .font(MudraTheme.bodyFont)
                        .foregroundColor(MudraTheme.offBlack.opacity(0.85))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            InfoFloatCard(icon: "sparkles", tint: MudraTheme.mutedGold) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Significance")
                        .font(.system(.caption, design: .default).weight(.semibold))
                        .foregroundColor(MudraTheme.mutedGold)
                    Text(mudra.significance)
                        .font(MudraTheme.bodyFont)
                        .foregroundColor(MudraTheme.offBlack.opacity(0.85))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !mudra.meanings.isEmpty {
                Text("Meanings")
                    .font(.system(.headline, design: .default))
                    .foregroundColor(MudraTheme.offBlack)
                    .padding(.top, 4)

                ForEach(mudra.meanings) { meaning in
                    InfoFloatCard(icon: "bookmark.fill",
                                  tint: Color(red: 0.35, green: 0.55, blue: 0.40)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meaning.context)
                                .font(.system(.caption, design: .default).weight(.semibold))
                                .foregroundColor(Color(red: 0.35, green: 0.55, blue: 0.40))
                            Text(meaning.meaning)
                                .font(MudraTheme.bodyFont)
                                .foregroundColor(MudraTheme.offBlack.opacity(0.85))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, hPad)
    }

    private var practiceButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [MudraTheme.cream.opacity(0), MudraTheme.cream],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: 32)

            Button {
                showPractice = true
            } label: {
                Text("Practice")
                    .font(.system(.headline, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: isIPad ? 400 : .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(MudraTheme.crimsonRed)
                    )
            }
            .padding(.horizontal, hPad)
            .padding(.top, 4)
            .padding(.bottom, 36)
            .frame(maxWidth: .infinity)
            .background(MudraTheme.cream)
        }
    }
}


struct InfoFloatCard<Content: View>: View {
    let icon:    String
    let tint:    Color
    let content: () -> Content

    init(icon: String, tint: Color, @ViewBuilder content: @escaping () -> Content) {
        self.icon    = icon
        self.tint    = tint
        self.content = content
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(tint.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(tint)
            }
            .padding(.top, 2)

            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.80))
                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 3)
        )
    }
}


#Preview("Mudra Detail") {
    NavigationStack {
        MudraDetailView(mudra: MudraLibrary.pataka)
            .environmentObject(ProgressStore())
    }
}
