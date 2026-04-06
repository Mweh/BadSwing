import UIKit
import AVFoundation
import Combine

final class SwingDetectionViewController: UIViewController {

    private let viewModel: SwingDetectionViewModel
    private let cameraService: CameraService
    private let poseDetectionService: PoseDetectionService

    private let skeletonOverlayView = SkeletonOverlayView()
    private let feedbackLabel = UILabel()
    private let cameraContainerView = UIView()

    private var cancellables = Set<AnyCancellable>()
    private var previewLayer: AVCaptureVideoPreviewLayer?

    @MainActor
    init(
        viewModel: SwingDetectionViewModel? = nil,
        cameraService: CameraService? = nil,
        poseDetectionService: PoseDetectionService? = nil
    ) {
        self.viewModel = viewModel ?? SwingDetectionViewModel()
        self.cameraService = cameraService ?? CameraService()
        self.poseDetectionService = poseDetectionService ?? PoseDetectionService()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupCamera()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraService.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraService.stop()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraContainerView.bounds
    }

    private func setupLayout() {
        view.backgroundColor = .black

        cameraContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraContainerView)

        skeletonOverlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skeletonOverlayView)

        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackLabel.textAlignment = .center
        feedbackLabel.textColor = .white
        feedbackLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        feedbackLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        feedbackLabel.layer.cornerRadius = 12
        feedbackLabel.clipsToBounds = true
        feedbackLabel.text = "Get ready..."
        view.addSubview(feedbackLabel)

        NSLayoutConstraint.activate([
            cameraContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            skeletonOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            skeletonOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skeletonOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skeletonOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            feedbackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            feedbackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            feedbackLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            feedbackLabel.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setupCamera() {
        cameraService.delegate = self
        cameraService.configure()

        let layer = cameraService.previewLayer
        layer.videoGravity = .resizeAspectFill
        cameraContainerView.layer.addSublayer(layer)
        previewLayer = layer
    }

    private func bindViewModel() {
        viewModel.$currentSwingResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.updateFeedbackLabel(for: result)
            }
            .store(in: &cancellables)
    }

    private func updateFeedbackLabel(for result: SwingResult?) {
        UIView.animate(withDuration: 0.2) {
            self.feedbackLabel.alpha = 0
        } completion: { _ in
            self.feedbackLabel.text = result?.displayMessage ?? "Get ready..."
            UIView.animate(withDuration: 0.2) {
                self.feedbackLabel.alpha = 1
            }
        }
    }
}

extension SwingDetectionViewController: CameraServiceDelegate {
    nonisolated func cameraService(_ service: CameraService, didOutput sampleBuffer: CMSampleBuffer) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds

        if let frame = poseDetectionService.detectPose(in: sampleBuffer, timestamp: timestamp) {
            DispatchQueue.main.async { [weak self] in
                self?.skeletonOverlayView.update(with: frame)
            }
        }

        viewModel.process(sampleBuffer: sampleBuffer)
    }
}
