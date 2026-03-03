import SwiftUI

@MainActor private var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}

struct JourneyMapView: View {
    @EnvironmentObject var progressStore: ProgressStore

    private var hPad: CGFloat       { isIPad ? 48 : 20 }
    private var cardImageH: CGFloat { isIPad ? 280 : 190 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Daily Mudra Sadhana")
                .font(.system(.title, design: .default).weight(.bold))
                .foregroundColor(MudraTheme.offBlack)
                .padding(.horizontal, hPad)
                .padding(.top, isIPad ? 56 : 16)
                .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(spacing: isIPad ? 28 : 18) {
                    InfoCard(
                        title:       "Asamyukta Hasta",
                        description: "Single-hand gestures that convey emotions, actions and meaning in Bharatanatyam. The Abhinaya Darpana describes 28 Asamyukta mudras.",
                        imageName:   "asamyukta",
                        imageHeight: cardImageH,
                        destination: MudraGridView(category: .asamyukta)
                            .environmentObject(progressStore)
                    )

                    InfoCard(
                        title:       "Samyukta Hasta",
                        description: "Combined two-hand gestures used to depict deities, animals and nature in Bharatanatyam. The Abhinaya Darpana describes 23 Samyukta mudras.",
                        imageName:   "samyukta",
                        imageHeight: cardImageH,
                        destination: MudraGridView(category: .samyukta)
                            .environmentObject(progressStore)
                    )
                }
                .padding(.horizontal, hPad)
                .padding(.bottom, 40)
            }
        }
        .background(
            ZStack {
                MudraTheme.cream
                Image("temple_template")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.30)
            }
            .ignoresSafeArea()
        )
        .navigationBarHidden(true)
    }
}

struct InfoCard<Destination: View>: View {
    let title:       String
    let description: String
    let imageName:   String
    let imageHeight: CGFloat
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 0) {
                GeometryReader { geo in
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .frame(height: imageHeight)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(isIPad ? .title3 : .headline, design: .default).weight(.bold))
                        .foregroundColor(MudraTheme.offBlack)

                    Text(description)
                        .font(.system(isIPad ? .body : .footnote, design: .default))
                        .foregroundColor(MudraTheme.offBlack.opacity(0.75))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.92))
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.10), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}
