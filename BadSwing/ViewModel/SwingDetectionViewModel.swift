import Foundation
import Combine
import AVFoundation

final class SwingDetectionViewModel: ObservableObject {

    @Published private(set) var currentSwingResult: SwingResult?

    private let swingAnalyzerFacade: SwingAnalyzerFacade
    private let resultThrottleInterval: TimeInterval
    private var lastPublishedAt: TimeInterval = 0

    init(
        swingAnalyzerFacade: SwingAnalyzerFacade = SwingAnalyzerFacade(),
        resultThrottleInterval: TimeInterval = 1.0
    ) {
        self.swingAnalyzerFacade = swingAnalyzerFacade
        self.resultThrottleInterval = resultThrottleInterval
    }

    func process(sampleBuffer: CMSampleBuffer) {
        guard let result = swingAnalyzerFacade.process(sampleBuffer: sampleBuffer) else { return }

        let now = Date().timeIntervalSince1970
        guard now - lastPublishedAt >= resultThrottleInterval else { return }
        lastPublishedAt = now

        DispatchQueue.main.async { [weak self] in
            self?.currentSwingResult = result
        }
    }

    func reset() {
        swingAnalyzerFacade.reset()
        DispatchQueue.main.async { [weak self] in
            self?.currentSwingResult = nil
        }
    }
}
