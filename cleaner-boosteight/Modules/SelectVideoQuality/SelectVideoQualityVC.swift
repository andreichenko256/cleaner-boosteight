import UIKit
import SnapKit
import AVKit
import Combine

final class SelectVideoQualityViewController: UIViewController {
    
    
    private var electVideoQualityView: SelectVideoQualityView {
        return view as! SelectVideoQualityView
    }
    
    private let viewModel: SelectVideoQualityViewModelProtocol
    private var playerViewController: AVPlayerViewController?
    private var cancellables = Set<AnyCancellable>()
    
    
    init(viewModel: SelectVideoQualityViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        setupQualitySelector()
        setupCompressButton()
        bindViewModel()
        
        viewModel.loadVideo()
    }
    
    override func loadView() {
        view = SelectVideoQualityView()
    }
    
    deinit {
        viewModel.cleanup()
    }
}

private extension SelectVideoQualityViewController {
    func setupVideoPlayer() {
        let playerVC = AVPlayerViewController()
        playerVC.allowsPictureInPicturePlayback = false
        playerVC.showsPlaybackControls = true
        
        addChild(playerVC)
        electVideoQualityView.videoContainerView.addSubview(playerVC.view)
        playerVC.view.frame = electVideoQualityView.videoContainerView.bounds
        playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerVC.didMove(toParent: self)
        
        self.playerViewController = playerVC
    }
    
    func setupQualitySelector() {
        electVideoQualityView.qualitySelector.onQualitySelected = { [weak self] quality in
            self?.handleQualitySelection(quality)
        }
    }
    
    func setupCompressButton() {
        electVideoQualityView.compressButton.addTarget(
            self,
            action: #selector(compressButtonTapped),
            for: .touchUpInside
        )
    }
}

private extension SelectVideoQualityViewController {
    func bindViewModel() {
        viewModel.playerPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] player in
                self?.playerViewController?.player = player
            }
            .store(in: &cancellables)
        
        viewModel.selectedQualityPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quality in
                self?.electVideoQualityView.qualitySelector.setQuality(quality)
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
    }
}
private extension SelectVideoQualityViewController {
    func handleQualitySelection(_ quality: VideoQuality) {
        viewModel.selectQuality(quality)
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc func compressButtonTapped() {
        // TODO: Implement compression logic
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
