import Foundation
import CoreGraphics

enum MovingAverage {

    static func apply(to points: [CGPoint], windowSize: Int) -> [CGPoint] {
        guard windowSize > 0, !points.isEmpty else { return points }
        let clampedWindow = min(windowSize, points.count)

        return points.indices.map { index in
            let start = max(0, index - clampedWindow + 1)
            let window = points[start...index]
            let sumX = window.reduce(0) { $0 + $1.x }
            let sumY = window.reduce(0) { $0 + $1.y }
            let count = CGFloat(window.count)
            return CGPoint(x: sumX / count, y: sumY / count)
        }
    }

    static func apply(to values: [CGFloat], windowSize: Int) -> [CGFloat] {
        guard windowSize > 0, !values.isEmpty else { return values }
        let clampedWindow = min(windowSize, values.count)

        return values.indices.map { index in
            let start = max(0, index - clampedWindow + 1)
            let window = values[start...index]
            return window.reduce(0, +) / CGFloat(window.count)
        }
    }
}
