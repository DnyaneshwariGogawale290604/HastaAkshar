import SwiftUI
import AVFoundation
import Vision
import UIKit


struct ARPracticeView: View {
    let mudra:          Mudra
    var onExitToGrid:   (() -> Void)? = nil

    @EnvironmentObject var progressStore: ProgressStore
    @Environment(\.dismiss) var dismiss

    @StateObject private var detector      = HandPoseDetector()
    @StateObject private var cameraSession = CameraSession()

    
    @State private var activeMudra:     Mudra
    @State private var activeNext:      Mudra?


    @State private var passFrameCount  = 0
    @State private var showPassOverlay = false
    @State private var sessionDone     = false

 
    private let framesNeededToPass = 12

  
    init(mudra: Mudra, onExitToGrid: (() -> Void)? = nil) {
        self.mudra        = mudra
        self.onExitToGrid = onExitToGrid
        _activeMudra  = State(initialValue: mudra)
        _activeNext   = State(initialValue: Self.nextMudraAfter(mudra))
    }

    var body: some View {
        ZStack {
            
            CameraPreviewView(session: cameraSession.session)
                .ignoresSafeArea()

           
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

            
            if !showPassOverlay { referenceOverlay }

           
            VStack(spacing: 0) {
                topScoreRing
                Spacer()
                if !detector.handDetected { noHandPrompt }
                bottomFeedbackPanel
            }

            
            if detector.result.overallScore >= HandPoseResult.passThreshold
               && !showPassOverlay && detector.handDetected {
                correctFlash
            }

        
            if showPassOverlay {
                successOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(showPassOverlay)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(activeMudra.name.uppercased())
                    .font(MudraTheme.captionFont)
                    .kerning(2)
                    .foregroundColor(.white.opacity(0.85))
                    .id(activeMudra.id)
                    .transition(.opacity)
            }
        }
        .onAppear    { startSession() }
        .onDisappear { cameraSession.stop() }
        .onChange(of: detector.result.overallScore) { score in
            guard !sessionDone else { return }
            if score >= HandPoseResult.passThreshold {
                passFrameCount += 1
                if passFrameCount >= framesNeededToPass { triggerPass() }
            } else {
                passFrameCount = 0
            }
        }
    }

    private var refSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 100 : 70
    }

   
    private var referenceOverlay: some View {
        VStack {
            HStack {
                VStack(spacing: 4) {
                    if UIImage(named: activeMudra.illustrationAssetName) != nil {
                        Image(activeMudra.illustrationAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: refSize, height: refSize)
                            .padding(6)
                            .background(Color.white.opacity(0.78))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Text(activeMudra.name)
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
        .id(activeMudra.id)
    }

    private var ringSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 62 : 48
    }

    private var topScoreRing: some View {
        HStack {
            Spacer()
            ZStack {
                Circle().stroke(.white.opacity(0.2), lineWidth: 3).frame(width: ringSize, height: ringSize)
                Circle()
                    .trim(from: 0, to: detector.result.overallScore)
                    .stroke(ringColor(detector.result.overallScore),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.12), value: detector.result.overallScore)
                Text("\(Int(detector.result.overallScore * 100))%")
                    .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 13 : 11,
                                  weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.trailing, 16)
            .padding(.top, 12)
        }
    }

    private var correctFlash: some View {
        RoundedRectangle(cornerRadius: 28)
            .stroke(Color.green, lineWidth: 4)
            .padding(12)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    private var noHandPrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.raised").font(.system(size: 52))
                .foregroundColor(.white.opacity(0.4))
            Text("Raise your hand to the camera")
                .font(MudraTheme.bodyFont)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 20)
    }

    private var bottomFeedbackPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            if detector.result.overallScore >= HandPoseResult.passThreshold {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 20))
                        .foregroundColor(.green)
                    Text("Great job! Hold still…")
                        .font(MudraTheme.bodyFont.weight(.bold)).foregroundColor(.green)
                }
            } else if let hint = detector.result.primaryHint, detector.handDetected {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(MudraTheme.mutedGold)
                    Text(hint)
                        .font(MudraTheme.bodyFont.weight(.semibold))
                        .foregroundColor(.white)
                        .lineLimit(2).fixedSize(horizontal: false, vertical: true)
                }
            } else if detector.handDetected {
                HStack(spacing: 8) {
                    Image(systemName: "hand.point.up.left").font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.5))
                    Text("Keep adjusting…").font(MudraTheme.bodyFont)
                        .foregroundColor(.white.opacity(0.55))
                }
            }

            if !detector.result.secondaryHints.isEmpty
               && detector.result.overallScore < HandPoseResult.passThreshold {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(detector.result.secondaryHints, id: \.self) { hint in
                        HStack(spacing: 6) {
                            Circle().fill(MudraTheme.mutedGold.opacity(0.7)).frame(width: 5, height: 5)
                            Text(hint).font(MudraTheme.captionFont).foregroundColor(.white.opacity(0.7))
                        }
                    }
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
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.12), lineWidth: 1))
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    private var successOverlay: some View {
        let checkSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 110 : 80
        return ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: UIDevice.current.userInterfaceIdiom == .pad ? 26 : 18) {
                ZStack {
                    Circle().fill(Color.green).frame(width: checkSize, height: checkSize)
                        .shadow(color: Color.green.opacity(0.45), radius: 24)
                    Image(systemName: "checkmark")
                        .font(.system(size: checkSize * 0.45, weight: .bold)).foregroundColor(.white)
                }

                VStack(spacing: 6) {
                    Text("Good Job!")
                        .font(.system(UIDevice.current.userInterfaceIdiom == .pad ? .title2 : .headline,
                                      design: .default).weight(.semibold))
                        .foregroundColor(.white)
                    Text("\(activeMudra.name) Mudra Correct")
                        .font(MudraTheme.bodyFont.italic()).foregroundColor(.white.opacity(0.70))
                    Text("Accuracy - \(Int(detector.result.overallScore * 100))%")
                        .font(MudraTheme.captionFont).foregroundColor(.white.opacity(0.45))
                        .padding(.top, 2)
                }

                HStack(spacing: 14) {
                    Button {
                        cameraSession.stop()
                        dismiss()
                        let exitHandler = onExitToGrid
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            exitHandler?()
                        }
                    } label: {
                        Text("Exit")
                            .font(.system(.subheadline, design: .default).weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24).padding(.vertical, 12)
                            .background(
                                Capsule().fill(Color.white.opacity(0.18))
                                    .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                            )
                    }

                    if activeNext != nil {
                        Button { advanceToNext() } label: {
                            HStack(spacing: 6) {
                                Text("Next Mudra").font(.system(.subheadline, design: .default).weight(.semibold))
                                Image(systemName: "arrow.right").font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 22).padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(MudraTheme.crimsonRed)
                                    .shadow(color: MudraTheme.crimsonRed.opacity(0.4), radius: 12)
                            )
                        }
                    }
                }
            }
            .padding(UIDevice.current.userInterfaceIdiom == .pad ? 40 : 24)
        }
    }

    private func startSession() {
        detector.setPoseTarget(activeMudra.poseTarget)
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

    
    private func advanceToNext() {
        guard let next = activeNext else { return }

        
        let nextNext = Self.nextMudraAfter(next)

        withAnimation(.easeInOut(duration: 0.25)) {
            showPassOverlay = false
        }

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Reset detection state
            passFrameCount = 0
            sessionDone    = false
            activeMudra    = next
            activeNext     = nextNext

            
            detector.setPoseTarget(next.poseTarget)

           
            let cam = cameraSession
            if !cam.session.isRunning {
                cam.start()
            }
        }
    }

    private func triggerPass() {
        guard !sessionDone else { return }
        sessionDone = true
        cameraSession.stop()

     
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
            showPassOverlay = true
        }

        progressStore.recordResult(PracticeResult(
            mudraId:       activeMudra.id,
            accuracyScore: detector.result.overallScore,
            jointFeedback: (detector.result.secondaryHints
                            + [detector.result.primaryHint ?? ""])
                            .filter { !$0.isEmpty },
            passed:        true
        ))
    }

    private func ringColor(_ score: Double) -> Color {
        score >= 0.70 ? .green
            : score >= 0.45 ? MudraTheme.mutedGold
            : .white.opacity(0.5)
    }


    private static func nextMudraAfter(_ m: Mudra) -> Mudra? {
        let list = m.category == .asamyukta
            ? MudraLibrary.asamyuktaMudras
            : MudraLibrary.samyuktaMudras
        guard let idx = list.firstIndex(where: { $0.id == m.id }),
              idx + 1 < list.count else { return nil }
        return list[idx + 1]
    }
}


struct HandSkeletonOverlay: View {
    let allLandmarks: [[VNHumanHandPoseObservation.JointName: CGPoint]]
    let feedback:     [JointFeedback]
    let size:         CGSize

    // Back-compat single-hand init.
    init(landmarks: [VNHumanHandPoseObservation.JointName: CGPoint],
         feedback: [JointFeedback], size: CGSize) {
        self.allLandmarks = [landmarks]
        self.feedback     = feedback
        self.size         = size
    }
    /// Multi-hand init.
    init(allLandmarks: [[VNHumanHandPoseObservation.JointName: CGPoint]],
         feedback: [JointFeedback], size: CGSize) {
        self.allLandmarks = allLandmarks
        self.feedback     = feedback
        self.size         = size
    }

    private static let bones: [(VNHumanHandPoseObservation.JointName,
                                 VNHumanHandPoseObservation.JointName)] = [
        (.wrist,.thumbCMC),(.thumbCMC,.thumbMP),(.thumbMP,.thumbIP),(.thumbIP,.thumbTip),
        (.wrist,.indexMCP),(.indexMCP,.indexPIP),(.indexPIP,.indexDIP),(.indexDIP,.indexTip),
        (.wrist,.middleMCP),(.middleMCP,.middlePIP),(.middlePIP,.middleDIP),(.middleDIP,.middleTip),
        (.wrist,.ringMCP),(.ringMCP,.ringPIP),(.ringPIP,.ringDIP),(.ringDIP,.ringTip),
        (.wrist,.littleMCP),(.littleMCP,.littlePIP),(.littlePIP,.littleDIP),(.littleDIP,.littleTip),
        (.indexMCP,.middleMCP),(.middleMCP,.ringMCP),(.ringMCP,.littleMCP)
    ]

    var body: some View {
        Canvas { ctx, canvasSize in
            for (handIdx, lm) in allLandmarks.enumerated() {
                let boneAlpha: CGFloat = handIdx == 0 ? 0.45 : 0.55
                for (a, b) in Self.bones {
                    guard let p1 = pt(a, in: lm, size: canvasSize),
                          let p2 = pt(b, in: lm, size: canvasSize) else { continue }
                    var path = Path(); path.move(to: p1); path.addLine(to: p2)
                    ctx.stroke(path, with: .color(.white.opacity(boneAlpha)),
                               style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                }
                for (joint, _) in lm {
                    guard let p = pt(joint, in: lm, size: canvasSize) else { continue }
                    let r: CGFloat = 7
                    let rect = CGRect(x: p.x-r, y: p.y-r, width: r*2, height: r*2)
                    ctx.fill(Path(ellipseIn: rect), with: .color(jointColor(joint)))
                    ctx.stroke(Path(ellipseIn: rect.insetBy(dx: -1, dy: -1)),
                               with: .color(.white.opacity(0.6)), lineWidth: 1)
                }
            }
        }
    }

    private func pt(_ j: VNHumanHandPoseObservation.JointName,
                    in lm: [VNHumanHandPoseObservation.JointName: CGPoint],
                    size: CGSize) -> CGPoint? {
        guard let n = lm[j] else { return nil }
        return CGPoint(x: n.x * size.width, y: n.y * size.height)
    }

    private func jointColor(_ j: VNHumanHandPoseObservation.JointName) -> Color {
        let match = feedback.first { belongs(j, to: $0.finger) }
        switch match?.status {
        case .correct:   return .green
        case .close:     return Color(UIColor(red:0.79,green:0.66,blue:0.30,alpha:1))
        case .incorrect: return Color(UIColor(red:0.85,green:0.22,blue:0.22,alpha:1))
        case nil:        return .white.opacity(0.75)
        }
    }

    private func belongs(_ j: VNHumanHandPoseObservation.JointName, to f: Finger) -> Bool {
        switch f {
        case .thumb:  return [.thumbCMC,.thumbMP,.thumbIP,.thumbTip].contains(j)
        case .index:  return [.indexMCP,.indexPIP,.indexDIP,.indexTip].contains(j)
        case .middle: return [.middleMCP,.middlePIP,.middleDIP,.middleTip].contains(j)
        case .ring:   return [.ringMCP,.ringPIP,.ringDIP,.ringTip].contains(j)
        case .little: return [.littleMCP,.littlePIP,.littleDIP,.littleTip].contains(j)
        }
    }
}
