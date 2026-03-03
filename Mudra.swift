import Foundation
import SwiftUI

enum MudraCategory: String, Codable, CaseIterable {
    case asamyukta = "Asamyukta"
    case samyukta  = "Samyukta"

    var displayName: String { rawValue }
    var subtitle: String {
        switch self {
        case .asamyukta: return "Single Hand Gestures"
        case .samyukta:  return "Double Hand Gestures"
        }
    }
}

enum Finger: String, Codable, CaseIterable {
    case thumb, index, middle, ring, little
}

enum Joint: String, Codable {
    case mcp, pip, dip, tip
}

enum FingerState: String, Codable {
    case straight, slightlyBent, halfBent, fullyBent, curled, spread
}

struct JointAngleTarget: Codable {
    let finger: Finger
    let joint:  Joint
    let minAngle: Double
    let maxAngle: Double
    let tolerance: Double
    let correctionHint: String
}

struct ARPoseTarget: Codable {
    let jointTargets: [JointAngleTarget]
    let fingerStates: [Finger: FingerState]
    let dominantHand: HandSide

    enum HandSide: String, Codable {
        case right, left, both
    }

    enum CodingKeys: String, CodingKey {
        case jointTargets, dominantHand, fingerStatesRaw
    }

    init(jointTargets: [JointAngleTarget],
         fingerStates: [Finger: FingerState],
         dominantHand: HandSide) {
        self.jointTargets  = jointTargets
        self.fingerStates  = fingerStates
        self.dominantHand  = dominantHand
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        jointTargets = try c.decode([JointAngleTarget].self, forKey: .jointTargets)
        dominantHand = try c.decode(HandSide.self, forKey: .dominantHand)
        let raw = try c.decode([String: FingerState].self, forKey: .fingerStatesRaw)
        var states: [Finger: FingerState] = [:]
        for (k, v) in raw { if let f = Finger(rawValue: k) { states[f] = v } }
        fingerStates = states
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(jointTargets, forKey: .jointTargets)
        try c.encode(dominantHand, forKey: .dominantHand)
        let raw = Dictionary(uniqueKeysWithValues: fingerStates.map { ($0.key.rawValue, $0.value) })
        try c.encode(raw, forKey: .fingerStatesRaw)
    }
}

struct MudraMeaning: Codable, Identifiable {
    let id: UUID
    let context: String
    let meaning: String

    init(context: String, meaning: String) {
        self.id      = UUID()
        self.context = context
        self.meaning = meaning
    }
}

struct Mudra: Identifiable, Codable {
    let id: UUID
    let name: String
    let sanskritName: String
    let category: MudraCategory
    let orderIndex: Int
    let shortDescription: String
    let significance: String
    let meanings: [MudraMeaning]
    let poseTarget: ARPoseTarget
    var isUnlocked: Bool
    var isCompleted: Bool
    let illustrationAssetName: String

    init(id: UUID = UUID(),
         name: String,
         sanskritName: String,
         category: MudraCategory,
         orderIndex: Int,
         shortDescription: String,
         significance: String,
         meanings: [MudraMeaning],
         poseTarget: ARPoseTarget,
         isUnlocked: Bool = false,
         isCompleted: Bool = false,
         illustrationAssetName: String) {
        self.id                   = id
        self.name                 = name
        self.sanskritName         = sanskritName
        self.category             = category
        self.orderIndex           = orderIndex
        self.shortDescription     = shortDescription
        self.significance         = significance
        self.meanings             = meanings
        self.poseTarget           = poseTarget
        self.isUnlocked           = isUnlocked
        self.isCompleted          = isCompleted
        self.illustrationAssetName = illustrationAssetName
    }
}

extension Mudra: Hashable {
    static func == (lhs: Mudra, rhs: Mudra) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct PracticeResult: Identifiable, Codable {
    let id: UUID
    let mudraId: UUID
    let date: Date
    let accuracyScore: Double
    let jointFeedback: [String]
    let passed: Bool

    init(mudraId: UUID,
         accuracyScore: Double,
         jointFeedback: [String],
         passed: Bool) {
        self.id            = UUID()
        self.mudraId       = mudraId
        self.date          = Date()
        self.accuracyScore = accuracyScore
        self.jointFeedback = jointFeedback
        self.passed        = passed
    }
}
