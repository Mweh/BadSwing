import UIKit
import CoreGraphics

final class SkeletonOverlayView: UIView {

    private var poseFrame: PoseFrame?

    private let jointRadius: CGFloat = 8
    private let jointColor: UIColor = .systemYellow
    private let boneColor: UIColor = UIColor.systemGreen.withAlphaComponent(0.8)
    private let lineWidth: CGFloat = 3

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with frame: PoseFrame?) {
        poseFrame = frame
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let frame = poseFrame, let context = UIGraphicsGetCurrentContext() else { return }

        let shoulder = convertedPoint(frame.shoulder)
        let elbow = convertedPoint(frame.elbow)
        let wrist = convertedPoint(frame.wrist)

        drawBone(from: shoulder, to: elbow, in: context)
        drawBone(from: elbow, to: wrist, in: context)

        drawJoint(at: shoulder, in: context)
        drawJoint(at: elbow, in: context)
        drawJoint(at: wrist, in: context)
    }

    private func convertedPoint(_ normalized: CGPoint) -> CGPoint {
        CGPoint(x: normalized.x * bounds.width, y: normalized.y * bounds.height)
    }

    private func drawBone(from start: CGPoint, to end: CGPoint, in context: CGContext) {
        context.setStrokeColor(boneColor.cgColor)
        context.setLineWidth(lineWidth)
        context.move(to: start)
        context.addLine(to: end)
        context.strokePath()
    }

    private func drawJoint(at point: CGPoint, in context: CGContext) {
        let rect = CGRect(
            x: point.x - jointRadius,
            y: point.y - jointRadius,
            width: jointRadius * 2,
            height: jointRadius * 2
        )
        context.setFillColor(jointColor.cgColor)
        context.fillEllipse(in: rect)
    }
}
