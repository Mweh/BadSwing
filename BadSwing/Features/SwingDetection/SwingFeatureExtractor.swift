import Foundation
import CoreGraphics

final class SwingFeatureExtractor {

    private let smoothingWindowSize: Int

    init(smoothingWindowSize: Int = 5) {
        self.smoothingWindowSize = smoothingWindowSize
    }

    func extract(from buffer: PoseSequenceBuffer) -> SwingFeatures? {
        let frames = buffer.allFrames
        guard frames.count >= 2, let startFrame = buffer.startFrame, let endFrame = buffer.endFrame else {
            return nil
        }

        let smoothedWrists = smoothedPoints(keyPath: \.wrist, frames: frames)
        let smoothedShoulders = smoothedPoints(keyPath: \.shoulder, frames: frames)

        guard
            let firstSmoothedWrist = smoothedWrists.first,
            let lastSmoothedWrist = smoothedWrists.last,
            let lastSmoothedShoulder = smoothedShoulders.last
        else { return nil }

        let shoulderWidth = shoulderSpan(frames: frames)
        let deltaX = normalizedDeltaX(
            start: firstSmoothedWrist,
            end: lastSmoothedWrist,
            shoulderWidth: shoulderWidth
        )

        let velocity = computeVelocity(
            start: startFrame,
            end: endFrame,
            smoothedWrists: smoothedWrists,
            shoulderWidth: shoulderWidth
        )

        let finalElbowAngle = PoseGeometry.angle(
            a: endFrame.shoulder,
            vertex: endFrame.elbow,
            b: endFrame.wrist
        )

        let crossedBody = lastSmoothedWrist.x < lastSmoothedShoulder.x

        return SwingFeatures(
            deltaX: deltaX,
            velocity: velocity,
            finalElbowAngle: finalElbowAngle,
            crossedBody: crossedBody
        )
    }

    private func smoothedPoints(keyPath: KeyPath<PoseFrame, CGPoint>, frames: [PoseFrame]) -> [CGPoint] {
        let raw = frames.map { $0[keyPath: keyPath] }
        return MovingAverage.apply(to: raw, windowSize: smoothingWindowSize)
    }

    private func shoulderSpan(frames: [PoseFrame]) -> CGFloat {
        let widths = frames.map { abs($0.shoulder.x) }
        let average = widths.reduce(0, +) / CGFloat(widths.count)
        return max(average, 0.01)
    }

    private func normalizedDeltaX(start: CGPoint, end: CGPoint, shoulderWidth: CGFloat) -> CGFloat {
        (end.x - start.x) / shoulderWidth
    }

    private func computeVelocity(
        start: PoseFrame,
        end: PoseFrame,
        smoothedWrists: [CGPoint],
        shoulderWidth: CGFloat
    ) -> CGFloat {
        let duration = end.timestamp - start.timestamp
        guard duration > 0, let first = smoothedWrists.first, let last = smoothedWrists.last else {
            return 0
        }
        let distance = abs(last.x - first.x) / shoulderWidth
        return distance / CGFloat(duration)
    }
}
