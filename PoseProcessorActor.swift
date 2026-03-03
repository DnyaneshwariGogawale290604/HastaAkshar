import Vision
import AVFoundation

struct PoseUpdate: @unchecked Sendable {
    let allLandmarks: [[VNHumanHandPoseObservation.JointName: CGPoint]]
    let result:       HandPoseResult
    let handDetected: Bool

    var landmarks: [VNHumanHandPoseObservation.JointName: CGPoint] {
        allLandmarks.first ?? [:]
    }

    static let empty = PoseUpdate(allLandmarks: [], result: .empty, handDetected: false)
}

actor PoseProcessorActor {

    private(set) var poseTarget: ARPoseTarget?

    func setPoseTarget(_ target: ARPoseTarget?) {
        poseTarget = target
    }

    private let request: VNDetectHumanHandPoseRequest = {
        let r = VNDetectHumanHandPoseRequest()
        r.maximumHandCount = 2
        return r
    }()

    private static let allJoints: [VNHumanHandPoseObservation.JointName] = [
        .wrist,
        .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
        .indexMCP, .indexPIP, .indexDIP, .indexTip,
        .middleMCP, .middlePIP, .middleDIP, .middleTip,
        .ringMCP,   .ringPIP,   .ringDIP,   .ringTip,
        .littleMCP, .littlePIP, .littleDIP, .littleTip
    ]

    func process(sampleBuffer: CMSampleBuffer) -> PoseUpdate {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return .empty
        }

        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        do {
            try handler.perform([request])
        } catch {
            return .empty
        }

        let observations = request.results ?? []
        guard !observations.isEmpty else { return .empty }

        let handsData = observations.map { obs -> ([VNHumanHandPoseObservation.JointName: CGPoint], HandPoseResult) in
            let pts      = extractPoints(from: obs)
            let feedback = poseTarget.map { computeFeedback(pts: pts, target: $0) } ?? []
            let result   = buildResult(feedback: feedback)
            return (pts, result)
        }

        let allLandmarkSets = handsData.map { $0.0 }

        let isSamyukta = poseTarget?.dominantHand == nil
        let combinedResult: HandPoseResult

        if isSamyukta && handsData.count >= 2 {
            let score1 = handsData[0].1.overallScore
            let score2 = handsData[1].1.overallScore
            let avgScore = (score1 + score2) / 2.0

            let hints1 = [handsData[0].1.primaryHint].compactMap { $0 }
            let hints2 = [handsData[1].1.primaryHint].compactMap { $0 }
            let combinedHints = (hints1 + hints2).uniqued()

            let merged = HandPoseResult(
                feedback:       handsData[0].1.feedback + handsData[1].1.feedback,
                overallScore:   avgScore,
                passed:         avgScore >= HandPoseResult.passThreshold,
                primaryHint:    combinedHints.first,
                secondaryHints: Array(combinedHints.dropFirst().prefix(2))
            )
            combinedResult = merged
        } else {
            combinedResult = handsData.map { $0.1 }.max(by: { $0.overallScore < $1.overallScore }) ?? .empty
        }

        return PoseUpdate(
            allLandmarks: allLandmarkSets,
            result:       combinedResult,
            handDetected: true
        )
    }

    private func extractPoints(
        from obs: VNHumanHandPoseObservation
    ) -> [VNHumanHandPoseObservation.JointName: CGPoint] {
        var pts: [VNHumanHandPoseObservation.JointName: CGPoint] = [:]
        for joint in Self.allJoints {
            if let pt = try? obs.recognizedPoint(joint), pt.confidence > 0.3 {
                pts[joint] = CGPoint(x: pt.location.x, y: 1.0 - pt.location.y)
            }
        }
        return pts
    }

    private func computeFeedback(
        pts: [VNHumanHandPoseObservation.JointName: CGPoint],
        target: ARPoseTarget
    ) -> [JointFeedback] {
        target.jointTargets.compactMap { jt in
            guard
                let triplet  = jt.joint.triplet(for: jt.finger),
                let proximal = pts[triplet.proximal],
                let vertex   = pts[triplet.middle],
                let distal   = pts[triplet.distal]
            else { return nil }

            let angle = bendAngle(proximal: proximal, vertex: vertex, distal: distal)

            let status: JointFeedback.Status
            if angle >= jt.minAngle && angle <= jt.maxAngle {
                status = .correct
            } else if angle >= jt.minAngle - jt.tolerance &&
                      angle <= jt.maxAngle + jt.tolerance {
                status = .close
            } else {
                status = .incorrect
            }

            return JointFeedback(
                finger: jt.finger, joint: jt.joint,
                measuredAngle: angle,
                targetMin: jt.minAngle, targetMax: jt.maxAngle,
                hint: jt.correctionHint, status: status
            )
        }
    }

    private func buildResult(feedback: [JointFeedback]) -> HandPoseResult {
        guard !feedback.isEmpty else { return .empty }
        let score          = feedback.map(\.score).reduce(0, +) / Double(feedback.count)
        let incorrectHints = feedback.filter { $0.status == .incorrect }
                                     .sorted { $0.score < $1.score }.map(\.hint)
        let allHints       = incorrectHints + feedback.filter { $0.status == .close }.map(\.hint)
        return HandPoseResult(
            feedback: feedback, overallScore: score,
            passed: score >= HandPoseResult.passThreshold,
            primaryHint: allHints.first,
            secondaryHints: Array(allHints.dropFirst().prefix(2))
        )
    }
}

private func bendAngle(proximal: CGPoint, vertex: CGPoint, distal: CGPoint) -> Double {
    let v1 = CGVector(dx: proximal.x - vertex.x, dy: proximal.y - vertex.y)
    let v2 = CGVector(dx: distal.x   - vertex.x, dy: distal.y   - vertex.y)
    let dot  = v1.dx * v2.dx + v1.dy * v2.dy
    let mag1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy)
    let mag2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy)
    guard mag1 > 1e-6, mag2 > 1e-6 else { return 0 }
    let cosA = max(-1.0, min(1.0, dot / (mag1 * mag2)))
    return 180.0 - acos(cosA) * 180.0 / .pi
}

private extension Joint {
    typealias JN = VNHumanHandPoseObservation.JointName
    func triplet(for finger: Finger) -> (proximal: JN, middle: JN, distal: JN)? {
        switch (finger, self) {
        case (.index,  .mcp): return (.wrist,     .indexMCP,  .indexPIP)
        case (.index,  .pip): return (.indexMCP,  .indexPIP,  .indexDIP)
        case (.index,  .dip): return (.indexPIP,  .indexDIP,  .indexTip)
        case (.middle, .mcp): return (.wrist,     .middleMCP, .middlePIP)
        case (.middle, .pip): return (.middleMCP, .middlePIP, .middleDIP)
        case (.middle, .dip): return (.middlePIP, .middleDIP, .middleTip)
        case (.ring,   .mcp): return (.wrist,     .ringMCP,   .ringPIP)
        case (.ring,   .pip): return (.ringMCP,   .ringPIP,   .ringDIP)
        case (.ring,   .dip): return (.ringPIP,   .ringDIP,   .ringTip)
        case (.little, .mcp): return (.wrist,     .littleMCP, .littlePIP)
        case (.little, .pip): return (.littleMCP, .littlePIP, .littleDIP)
        case (.little, .dip): return (.littlePIP, .littleDIP, .littleTip)
        case (.thumb,  .mcp): return (.thumbCMC, .thumbMP, .thumbIP)
        case (.thumb,  .pip): return (.thumbMP,  .thumbIP, .thumbTip)
        case (.thumb,  .dip): return (.thumbMP,  .thumbIP, .thumbTip)
        default: return nil
        }
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
