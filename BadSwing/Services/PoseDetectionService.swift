import Vision
import CoreImage
import CoreGraphics

final class PoseDetectionService {

    private let requestHandler = VNSequenceRequestHandler()
    private let bodyPoseRequest = VNDetectHumanBodyPoseRequest()

    func detectPose(in sampleBuffer: CMSampleBuffer, timestamp: TimeInterval) -> PoseFrame? {
        guard
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            (try? requestHandler.perform([bodyPoseRequest], on: imageBuffer, orientation: .up)) != nil,
            let observation = bodyPoseRequest.results?.first
        else { return nil }

        return extractPoseFrame(from: observation, timestamp: timestamp)
    }

    private func extractPoseFrame(from observation: VNHumanBodyPoseObservation, timestamp: TimeInterval) -> PoseFrame? {
        guard
            let shoulder = normalizedPoint(from: observation, jointName: .rightShoulder),
            let elbow = normalizedPoint(from: observation, jointName: .rightElbow),
            let wrist = normalizedPoint(from: observation, jointName: .rightWrist)
        else { return nil }

        return PoseFrame(timestamp: timestamp, shoulder: shoulder, elbow: elbow, wrist: wrist)
    }

    private func normalizedPoint(
        from observation: VNHumanBodyPoseObservation,
        jointName: VNHumanBodyPoseObservation.JointName
    ) -> CGPoint? {
        guard
            let point = try? observation.recognizedPoint(jointName),
            point.confidence > 0.5
        else { return nil }

        return CGPoint(x: point.location.x, y: 1 - point.location.y)
    }
}
