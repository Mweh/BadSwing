import Foundation
import CoreGraphics

final class PoseSequenceBuffer {

    private let capacity: Int
    private var frames: [PoseFrame] = []

    var startFrame: PoseFrame? { frames.first }
    var endFrame: PoseFrame? { frames.last }
    var allFrames: [PoseFrame] { frames }
    var isFull: Bool { frames.count >= capacity }

    init(capacity: Int = 30) {
        self.capacity = capacity
    }

    func append(_ frame: PoseFrame) {
        if frames.count >= capacity {
            frames.removeFirst()
        }
        frames.append(frame)
    }

    func reset() {
        frames.removeAll()
    }
}
