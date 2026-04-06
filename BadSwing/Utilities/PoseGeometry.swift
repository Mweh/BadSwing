import Foundation
import CoreGraphics

enum PoseGeometry {

    static func angle(a: CGPoint, vertex: CGPoint, b: CGPoint) -> CGFloat {
        let vectorAVertex = CGVector(dx: a.x - vertex.x, dy: a.y - vertex.y)
        let vectorBVertex = CGVector(dx: b.x - vertex.x, dy: b.y - vertex.y)

        let dotProduct = vectorAVertex.dx * vectorBVertex.dx + vectorAVertex.dy * vectorBVertex.dy
        let magnitudeA = sqrt(vectorAVertex.dx * vectorAVertex.dx + vectorAVertex.dy * vectorAVertex.dy)
        let magnitudeB = sqrt(vectorBVertex.dx * vectorBVertex.dx + vectorBVertex.dy * vectorBVertex.dy)

        let denominator = magnitudeA * magnitudeB
        guard denominator != 0 else { return 0 }

        let cosine = (dotProduct / denominator).clamped(to: -1...1)
        return acos(cosine) * (180 / .pi)
    }

    static func distance(from pointA: CGPoint, to pointB: CGPoint) -> CGFloat {
        let dx = pointB.x - pointA.x
        let dy = pointB.y - pointA.y
        return sqrt(dx * dx + dy * dy)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
