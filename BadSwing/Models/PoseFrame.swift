import Foundation
import CoreGraphics

struct PoseFrame {
    let timestamp: TimeInterval
    let shoulder: CGPoint
    let elbow: CGPoint
    let wrist: CGPoint
}
