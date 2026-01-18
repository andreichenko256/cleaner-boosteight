import UIKit

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    
    private var mediaViewModel: MediaViewModel?
    private var duplicatePhotosViewModel: DuplicatePhotosViewModel?
    private var similarPhotosViewModel: SimilarPhotosViewModel?
    private var similarVideosViewModel: SimilarVideosViewModel?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainScreen()
    }
    
    func finish() {
        removeAllChildren()
    }
}

private extension MainCoordinator {
    func showMainScreen() {
        let viewModel = MainViewModel()
        viewModel.onMediaGroupTapped = { [weak self] mediaType in
            switch mediaType {
            case .videoCompressor:
                self?.showVideoCompressor()
            case .media:
                self?.showMedia()
            }
        }
        
        let mainVC = MainViewController(viewModel: viewModel)
        navigationController.setViewControllers([mainVC], animated: false)
    }
    
    func showVideoCompressor() {
        let videoCompressorCoordinator = VideoCompressorCoordinator(navigationController: navigationController)
        
        videoCompressorCoordinator.onFinish = { [weak self] in
            self?.removeChild(videoCompressorCoordinator)
        }
        
        addChild(videoCompressorCoordinator)
        videoCompressorCoordinator.start()
    }
    
    func showMedia() {
        if mediaViewModel == nil {
            mediaViewModel = MediaViewModel()
            mediaViewModel?.onMediaItemTapped = { [weak self] mediaType in
                self?.handleMediaItemTap(mediaType)
            }
        }
        
        guard let viewModel = mediaViewModel else { return }
        
        let mediaVC = MediaViewController(viewModel: viewModel)
        navigationController.pushViewController(mediaVC, animated: true)
    }
    
    func handleMediaItemTap(_ type: MediaItemType) {
        switch type {
        case .screenshots:
            showScreenPhotos()
        case .livePhotos:
            showLivePhotos()
        case .screenRecordings:
            showScreenRecordings()
        case .duplicatePhotos:
            showDuplicatePhotos()
        case .similarPhotos:
            showSimilarPhotos()
        case .similarVideos:
            showSimilarVideos()
        }
    }
    
    func showScreenPhotos() {
        let screenPhotosVC = ScreenPhotosViewController()
        navigationController.pushViewController(screenPhotosVC, animated: true)
    }
    
    func showDuplicatePhotos() {
        if duplicatePhotosViewModel == nil {
            duplicatePhotosViewModel = DuplicatePhotosViewModel()
        }
        
        guard let viewModel = duplicatePhotosViewModel else { return }
        let duplicatePhotosVC = DuplicatePhotosViewController(viewModel: viewModel)
        navigationController.pushViewController(duplicatePhotosVC, animated: true)
    }
    
    func showSimilarPhotos() {
        if similarPhotosViewModel == nil {
            similarPhotosViewModel = SimilarPhotosViewModel()
        }
        
        guard let viewModel = similarPhotosViewModel else { return }
        let similarPhotosVC = SimilarPhotosViewController(viewModel: viewModel)
        navigationController.pushViewController(similarPhotosVC, animated: true)
    }
    
    func showLivePhotos() {
        let livePhotosVC = LivePhotosViewController()
        navigationController.pushViewController(livePhotosVC, animated: true)
    }
    
    func showScreenRecordings() {
        let screenRecordingsVC = ScreenRecordingsViewController()
        navigationController.pushViewController(screenRecordingsVC, animated: true)
    }
    
    func showSimilarVideos() {
        if similarVideosViewModel == nil {
            similarVideosViewModel = SimilarVideosViewModel()
        }
        
        guard let viewModel = similarVideosViewModel else { return }
        let similarVideosVC = SimilarVideosViewController(viewModel: viewModel)
        navigationController.pushViewController(similarVideosVC, animated: true)
    }
}
