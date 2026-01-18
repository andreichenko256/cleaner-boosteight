import UIKit
import SnapKit
import AVKit
import Combine
import Photos

final class PreviewAfterCompressViewController: UIViewController {
    var onBack: VoidBlock?
    
    private var previewAfterCompressView: PreviewAfterCompressView {
        return view as! PreviewAfterCompressView
    }
    
    private let viewModel: PreviewAfterCompressViewModelProtocol
    private var playerViewController: AVPlayerViewController?
    private var cancellables = Set<AnyCancellable>()
    private var isNavigatingBack = false
    
    init(viewModel: PreviewAfterCompressViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayer()
        setupButtons()
        setupSwipeBackGesture()
        bindViewModel()
        loadVideo()
        viewModel.loadCompressedVideoSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func loadView() {
        view = PreviewAfterCompressView()
    }
    
    deinit {
        cleanup()
    }
}

extension PreviewAfterCompressViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            if !isNavigatingBack {
                isNavigatingBack = true
                onBack?()
                return false
            }
        }
        return true
    }
}

private extension PreviewAfterCompressViewController {
    func setupVideoPlayer() {
        let playerVC = AVPlayerViewController()
        playerVC.allowsPictureInPicturePlayback = false
        playerVC.showsPlaybackControls = true
        
        addChild(playerVC)
        previewAfterCompressView.videoContainerView.addSubview(playerVC.view)
        playerVC.view.frame = previewAfterCompressView.videoContainerView.bounds
        playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerVC.didMove(toParent: self)
        
        self.playerViewController = playerVC
    }
    
    func setupButtons() {
        previewAfterCompressView.keepOriginalButton.addTarget(
            self,
            action: #selector(keepOriginalButtonTapped),
            for: .touchUpInside
        )
        
        previewAfterCompressView.onDeleteTap = { [weak self] in
            self?.handleDeleteTap()
        }
        
        previewAfterCompressView.customNavigationBar.onBackTap = { [weak self] in
            self?.isNavigatingBack = true
            self?.onBack?()
        }
    }
    
    func setupSwipeBackGesture() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func bindViewModel() {
        previewAfterCompressView.sizeChangeView.updateSizes(
            now: viewModel.originalSize,
            willBe: viewModel.compressedSize
        )
        
        viewModel.compressedSizePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] compressedSize in
                self?.previewAfterCompressView.sizeChangeView.updateSizes(
                    now: self?.viewModel.originalSize ?? "",
                    willBe: compressedSize
                )
            }
            .store(in: &cancellables)
    }
    
    func loadVideo() {
        guard let videoURL = viewModel.compressedVideoURL else { return }
        loadVideoFromURL(videoURL)
    }
    
    func loadVideoFromURL(_ url: URL) {
        let playerItem = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: playerItem)
        playerViewController?.player = player
    }
    
    @objc func keepOriginalButtonTapped() {
        saveCompressedVideo()
    }
    
    func saveCompressedVideo() {
        Task {
            do {
                try await viewModel.saveCompressedVideoToLibrary()
                await MainActor.run {
                    isNavigatingBack = true
                    onBack?()
                }
            } catch {
                await MainActor.run {
                    showError("Failed to save compressed video: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func handleDeleteTap() {
        let alert = UIAlertController(
            title: "Delete Original Video",
            message: "Are you sure you want to delete the original video? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteOriginalVideo()
        })
        
        present(alert, animated: true)
    }
    
    func deleteOriginalVideo() {
        Task {
            do {
                try await viewModel.deleteOriginalVideo()
                await MainActor.run {
                    isNavigatingBack = true
                    onBack?()
                }
            } catch {
                await MainActor.run {
                    showError("Failed to delete original video: \(error.localizedDescription)")
                }
            }
        }
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
    
    func cleanup() {
        playerViewController?.player?.pause()
        playerViewController?.player = nil
        cancellables.removeAll()
    }
}
