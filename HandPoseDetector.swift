import Vision
import SwiftUI

struct JointFeedback: Sendable {
    let finger:        Finger
    let joint:         Joint
    let measuredAngle: Double
    let targetMin:     Double
    let targetMax:     Double
    let hint:          String
    let status:        Status

    enum Status: Sendable { case correct, close, incorrect }

    var isCorrect: Bool { status == .correct }

    var score: Double {
        let center   = (targetMin + targetMax) / 2.0
        let halfBand = (targetMax - targetMin) / 2.0 + 15.0
        let distance = abs(measuredAngle - center)
        return max(0, 1.0 - (distance / halfBand))
    }
}

struct HandPoseResult: Sendable {
    let feedback:       [JointFeedback]
    let overallScore:   Double
    let passed:         Bool
    let primaryHint:    String?
    let secondaryHints: [String]

    static let passThreshold = 0.70
    static let empty = HandPoseResult(
        feedback: [], overallScore: 0,
        passed: false, primaryHint: nil, secondaryHints: []
    )
}

@MainActor
final class HandPoseDetector: ObservableObject {

    @Published var result:       HandPoseResult = .empty
    @Published var allLandmarks: [[VNHumanHandPoseObservation.JointName: CGPoint]] = []
    @Published var handDetected: Bool = false

    var landmarks: [VNHumanHandPoseObservation.JointName: CGPoint] {
        allLandmarks.first ?? [:]
    }

    let processor = PoseProcessorActor()

    func setPoseTarget(_ target: ARPoseTarget?) {
        Task { await processor.setPoseTarget(target) }
    }

    func apply(_ update: PoseUpdate) {
        if update.handDetected {
            handDetected = true
            allLandmarks = update.allLandmarks
            result       = update.result
        } else {
            handDetected  = false
            allLandmarks  = []
            result        = .empty
        }
    }
}
