import SwiftUI


@MainActor private var isIPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
}


struct MudraGridView: View {
    let category: MudraCategory
    @EnvironmentObject var progressStore: ProgressStore

    @State private var showSequence  = false
    @State private var scrollToId:   UUID? = nil

    private var mudras: [Mudra] {
        switch category {
        case .asamyukta: return MudraLibrary.asamyuktaMudras
        case .samyukta:  return MudraLibrary.samyuktaMudras
        }
    }

    private var columns: [GridItem] {
        let count: Int
        if isIPad {
            count = category == .asamyukta ? 3 : 2
        } else {
            count = category == .asamyukta ? 3 : 2
        }
        return Array(repeating: GridItem(.flexible(), spacing: isIPad ? 20 : 12), count: count)
    }

    private var hPad: CGFloat { isIPad ? 24 : 12 }

    var body: some View {
        ZStack(alignment: .bottom) {
            MudraTheme.cream.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: isIPad ? 20 : 12) {
                        ForEach(mudras) { mudra in
                            NavigationLink(destination:
                                MudraDetailView(mudra: mudra)
                                    .environmentObject(progressStore)
                            ) {
                                MudraCard(
                                    mudra:   mudra,
                                    compact: category == .asamyukta
                                )
                            }
                            .buttonStyle(.plain)
                            .id(mudra.id)
                        }
                    }
                    .padding(.horizontal, hPad)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
                .onAppear {
                    if let id = progressStore.lastPracticedId,
                       mudras.contains(where: { $0.id == id }) {
                        scrollToId = id
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation { proxy.scrollTo(id, anchor: .center) }
                        }
                    }
                }
                .onChange(of: progressStore.lastPracticedId) { id in
                    guard let id, mudras.contains(where: { $0.id == id }) else { return }
                    scrollToId = id
                    withAnimation { proxy.scrollTo(id, anchor: .center) }
                }
            }

            
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [MudraTheme.cream.opacity(0), MudraTheme.cream],
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: 28)

                NavigationLink(destination:
                    SequencePracticeView(mudras: mudras)
                        .environmentObject(progressStore)
                ) {
                    Text("Practice Sequence")
                        .font(.system(.callout, design: .default).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: isIPad ? 400 : .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(MudraTheme.crimsonRed)
                                .shadow(color: MudraTheme.crimsonRed.opacity(0.35), radius: 12, y: 5)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, isIPad ? 32 : 20)
                .padding(.bottom, 36)
                .background(MudraTheme.cream)
            }
        }
        .navigationTitle(category == .asamyukta ? "Asamyukta Hasta" : "Samyukta Hasta")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct MudraCard: View {
    let mudra:   Mudra
    let compact: Bool

    private var imageHeight: CGFloat {
        if isIPad {
            return compact ? 140 : 170
        } else {
            return compact ? 90 : 120
        }
    }

    var body: some View {
        VStack(spacing: 0) {
          
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 0.94)

                if UIImage(named: mudra.illustrationAssetName) != nil {
                    Image(mudra.illustrationAssetName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight - 16)
                        .padding(8)
                } else {
                    Image(systemName: "hand.raised")
                        .resizable()
                        .scaledToFit()
                        .frame(height: imageHeight - 32)
                        .foregroundColor(MudraTheme.altaRed.opacity(0.4))
                        .padding(16)
                }
            }
            .frame(height: imageHeight)

            Text(mudra.name)
                .font(.system(size: compact ? (isIPad ? 14 : 11) : (isIPad ? 16 : 13),
                              weight: .regular, design: .default))
                .foregroundColor(MudraTheme.offBlack)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.vertical, isIPad ? 10 : 6)
                .padding(.horizontal, 4)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: isIPad ? 14 : 10))
        .shadow(color: Color.black.opacity(0.07), radius: 6, y: 2)
    }
}


#Preview("Asamyukta Grid") {
    NavigationStack {
        MudraGridView(category: .asamyukta)
            .environmentObject(ProgressStore())
    }
}

#Preview("Samyukta Grid") {
    NavigationStack {
        MudraGridView(category: .samyukta)
            .environmentObject(ProgressStore())
    }
}
