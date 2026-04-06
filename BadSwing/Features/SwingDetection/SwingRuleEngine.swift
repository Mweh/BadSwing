import Foundation
import CoreGraphics

final class SwingRuleEngine {

    private let minimumDeltaX: CGFloat
    private let minimumVelocity: CGFloat
    private let minimumElbowAngle: CGFloat

    init(
        minimumDeltaX: CGFloat = 0.6,
        minimumVelocity: CGFloat = 0.8,
        minimumElbowAngle: CGFloat = 100.0
    ) {
        self.minimumDeltaX = minimumDeltaX
        self.minimumVelocity = minimumVelocity
        self.minimumElbowAngle = minimumElbowAngle
    }

    func evaluate(_ features: SwingFeatures) -> SwingResult {
        guard features.deltaX > 0.1 || features.crossedBody else {
            return .noSwing
        }

        if features.velocity < minimumVelocity {
            return .tooSlow
        }

        if features.finalElbowAngle < minimumElbowAngle {
            return .noExtension
        }

        if features.deltaX >= minimumDeltaX && features.crossedBody {
            return .good
        }

        return .noSwing
    }
}
