import AVFoundation
import Foundation

final class SwingAnalyzerFacade {

    private let poseDetectionService: PoseDetectionService
    private let poseSequenceBuffer: PoseSequenceBuffer
    private let swingFeatureExtractor: SwingFeatureExtractor
    private let swingRuleEngine: SwingRuleEngine

    init(
        poseDetectionService: PoseDetectionService = PoseDetectionService(),
        poseSequenceBuffer: PoseSequenceBuffer = PoseSequenceBuffer(capacity: 30),
        swingFeatureExtractor: SwingFeatureExtractor = SwingFeatureExtractor(),
        swingRuleEngine: SwingRuleEngine = SwingRuleEngine()
    ) {
        self.poseDetectionService = poseDetectionService
        self.poseSequenceBuffer = poseSequenceBuffer
        self.swingFeatureExtractor = swingFeatureExtractor
        self.swingRuleEngine = swingRuleEngine
    }

    func process(sampleBuffer: CMSampleBuffer) -> SwingResult? {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds

        guard let frame = poseDetectionService.detectPose(in: sampleBuffer, timestamp: timestamp) else {
            return nil
        }

        poseSequenceBuffer.append(frame)

        guard poseSequenceBuffer.isFull else { return nil }

        guard let features = swingFeatureExtractor.extract(from: poseSequenceBuffer) else {
            return nil
        }

        return swingRuleEngine.evaluate(features)
    }

    func reset() {
        poseSequenceBuffer.reset()
    }
}
