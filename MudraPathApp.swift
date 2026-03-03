import SwiftUI
import AVFoundation

@main
struct HastaAksharApp: App {
    @StateObject private var progressStore = ProgressStore()
    @State private var showHome = false

    var body: some Scene {
        WindowGroup {
            if showHome {
                NavigationStack {
                    JourneyMapView()
                }
                .tint(MudraTheme.altaRed)
                .environmentObject(progressStore)
            } else {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showHome = true
                    }
                }
            }
        }
    }
}

enum MudraTheme {
    static let altaRed    = Color(red: 0.753, green: 0.153, blue: 0.176)
    static let cream      = Color(red: 0.961, green: 0.902, blue: 0.851)
    static let offBlack   = Color(red: 0.102, green: 0.102, blue: 0.102)
    static let mutedGold  = Color(red: 0.788, green: 0.659, blue: 0.298)
    static let lockedGrey = Color(red: 0.780, green: 0.780, blue: 0.780)
    static let crimsonRed = Color(red: 144/255, green: 12/255, blue: 0/255)

    static let titleFont    : Font = .system(.title,       design: .default).weight(.semibold)
    static let headlineFont : Font = .system(.title3,      design: .default).weight(.medium)
    static let bodyFont     : Font = .system(.subheadline, design: .default)
    static let captionFont  : Font = .system(.caption,     design: .rounded).weight(.medium)
    static let sanskritFont : Font = .system(.footnote,    design: .default).italic()

    static let cardCornerRadius: CGFloat = 20
    static let dotSize: CGFloat          = 56
    static let screenPadding: CGFloat    = 20
}
