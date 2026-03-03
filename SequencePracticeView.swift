import SwiftUI
import AVFoundation
import Vision
import UIKit

// MARK: - SequencePracticeView

struct SequencePracticeView: View {
    let mudras: [Mudra]

    @EnvironmentObject var progressStore: ProgressStore
    @Environment(\.dismiss) var dismiss

    @StateObject private var detector      = HandPoseDetector()
    @StateObject private var cameraSession = CameraSession()

    @State private var currentIndex = 0
    @State private var passFrames   = 0
    @State private var showCheck    = false
    @State private var showDone     = false

    
    private let framesNeeded = 10

    private var currentMudra: Mudra { mudras[currentIndex] }
    private var isLast:       Bool  { currentIndex == mudras.count - 1 }

    var body: some View {
        ZStack {
           
            CameraPreviewView(session: cameraSession.session)
                .ignoresSafeArea()

            
            if !showCheck && !showDone {
                referenceOverlay
            }

            
            if detector.handDetected {
                GeometryReader { geo in
                    HandSkeletonOverlay(
                        allLandmarks: detector.allLandmarks,
                        feedback:     detector.result.feedback,
                        size:         geo.size
                    )
                }
                .ignoresSafeArea()
            }

            
            VStack(spacing: 0) {
                topBar
                Spacer()
                if !detector.handDetected && !showCheck { noHandPrompt }
                bottomPanel
            }

            
            if showCheck { checkFlash }

            
            if showDone { doneOverlay }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(showDone)
        .onAppear    { startCamera() }
        .onDisappear { cameraSession.stop() }
        
        .onChange(of: detector.result.overallScore) { score in
            guard !showCheck && !showDone else { return }
            if score >= HandPoseResult.passThreshold {
                passFrames += 1
                if passFrames >= framesNeeded { triggerAutoAdvance() }
            } else {
                passFrames = 0
            }
        }
    }

    private var refSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 100 : 70
    }

    // MARK: - Reference illustration
    private var referenceOverlay: some View {
        VStack {
            HStack {
                VStack(spacing: 4) {
                    if UIImage(named: currentMudra.illustrationAssetName) != nil {
                        Image(currentMudra.illustrationAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: refSize, height: refSize)
                            .padding(6)
                            .background(Color.white.opacity(0.78))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text(currentMudra.name)
                        .font(.system(.caption2, design: .default).weight(.semibold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 3)
                }
                .padding(.leading, 12)
                .padding(.top, 56)
                Spacer()
            }
            Spacer()
        }
        .id("ref-\(currentIndex)")
        .transition(.opacity)
    }

    private var seqRingSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 52 : 40
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(currentMudra.name)
                    .font(.system(UIDevice.current.userInterfaceIdiom == .pad ? .headline : .subheadline,
                                  design: .default))
                    .foregroundColor(.white)
                    .id("name-\(currentIndex)")
                    .transition(.opacity)
                Text("\(currentIndex + 1) of \(mudras.count)")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.65))
                    .id("count-\(currentIndex)")
                    .transition(.opacity)
            }
            .padding(.leading, 16)

            Spacer()

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 3)
                    .frame(width: seqRingSize, height: seqRingSize)
                Circle()
                    .trim(from: 0, to: detector.result.overallScore)
                    .stroke(ringColor(detector.result.overallScore),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: seqRingSize, height: seqRingSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.12), value: detector.result.overallScore)
                Text("\(Int(detector.result.overallScore * 100))%")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 12 : 10,
                                  weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 16)
        }
        .padding(.top, 12)
        .background(
            LinearGradient(colors: [Color.black.opacity(0.55), .clear],
                           startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        )
    }

    private var noHandPrompt: some View {
        VStack(spacing: 10) {
            Image(systemName: "hand.raised")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.4))
            Text("Raise your hand to the camera")
                .font(.system(.subheadline, design: .default))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.bottom, 16)
    }

    // MARK: - Bottom feedback panel
    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            if detector.result.overallScore >= HandPoseResult.passThreshold {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                    Text("Hold still…")
                        .font(.system(.subheadline, design: .default).weight(.semibold))
                        .foregroundColor(.green)
                }
            } else if let hint = detector.result.primaryHint, detector.handDetected {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(MudraTheme.mutedGold)
                    Text(hint)
                        .font(.system(.subheadline, design: .default).weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
            }

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.12)).frame(height: 5)
                    Capsule()
                        .fill(ringColor(detector.result.overallScore))
                        .frame(width: g.size.width * CGFloat(detector.result.overallScore), height: 5)
                        .animation(.easeInOut(duration: 0.12), value: detector.result.overallScore)
                }
            }
            .frame(height: 5)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 36)
    }

    
    private var checkFlash: some View {
        ZStack {
            Color.black.opacity(0.50).ignoresSafeArea()
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 90, height: 90)
                        .shadow(color: Color.green.opacity(0.5), radius: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Good Job!")
                    .font(.system(.title2, design: .default).weight(.semibold))
                    .foregroundColor(.white)
                Text(currentMudra.name)
                    .font(.system(.subheadline, design: .default).italic())
                    .foregroundColor(.white.opacity(0.70))
            }
        }
        .transition(.opacity)
    }

    // MARK: - Sequence Complete
    private var doneOverlay: some View {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        return ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()
            VStack(spacing: isPad ? 28 : 20) {
                Text("🏆").font(.system(size: isPad ? 72 : 52))
                VStack(spacing: 6) {
                    Text("Sequence Complete!")
                        .font(.system(isPad ? .title : .title3, design: .default).weight(.semibold))
                        .foregroundColor(.white)
                    Text("You completed all \(mudras.count) mudras!")
                        .font(.system(isPad ? .callout : .subheadline, design: .default).italic())
                        .foregroundColor(.white.opacity(0.65))
                }
                Button {
                    cameraSession.stop()
                    dismiss()
                } label: {
                    Text("Back to Grid")
                        .font(.system(isPad ? .body : .subheadline, design: .default).weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, isPad ? 48 : 32)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(MudraTheme.crimsonRed))
                }
            }
            .padding(isPad ? 40 : 24)
        }
    }

    // MARK: - Camera setup
    private func startCamera() {
        detector.setPoseTarget(currentMudra.poseTarget)
        let det = detector
        let cam = cameraSession
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else { return }
            Task { @MainActor [weak det, weak cam] in
                guard let det, let cam else { return }
                cam.configure(processor: det.processor) { [weak det] update in
                    det?.apply(update)
                }
                cam.start()
            }
        }
    }

    // MARK: - Advance logic
    private func triggerAutoAdvance() {
       
        passFrames = 0

       
        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(.success)

        
        progressStore.recordResult(PracticeResult(
            mudraId:       currentMudra.id,
            accuracyScore: detector.result.overallScore,
            jointFeedback: [],
            passed:        true
        ))

        if isLast {
            withAnimation { showDone = true }
        } else {
            
            withAnimation(.easeIn(duration: 0.18)) { showCheck = true }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.70) {
                withAnimation(.easeOut(duration: 0.18)) { showCheck = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    
                    currentIndex += 1
                    
                    detector.setPoseTarget(mudras[currentIndex].poseTarget)
                }
            }
        }
    }

    private func ringColor(_ score: Double) -> Color {
        score >= 0.70 ? .green
            : score >= 0.45 ? MudraTheme.mutedGold
            : .white.opacity(0.5)
    }
}


#Preview("Sequence") {
    NavigationStack {
        SequencePracticeView(mudras: MudraLibrary.asamyuktaMudras)
            .environmentObject(ProgressStore())
    }
}
