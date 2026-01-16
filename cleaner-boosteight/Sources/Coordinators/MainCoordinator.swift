import UIKit

final class MainCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
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
        let videoCompressorCoordinator = VideoCompressorCoordinator(
            navigationController: navigationController
        )
        
        videoCompressorCoordinator.onFinish = { [weak self] in
            self?.removeChild(videoCompressorCoordinator)
        }
        
        addChild(videoCompressorCoordinator)
        videoCompressorCoordinator.start()
    }
    
    func showMedia() {
        let viewModel = MediaViewModel()
        viewModel.onMediaItemTapped = { [weak self] mediaType in
            self?.handleMediaItemTap(mediaType)
        }
        
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
        case .duplicatePhotos, .similarPhotos, .similarVideos:
            break
        }
    }
    
    func showScreenPhotos() {
        let screenPhotosVC = ScreenPhotosViewController()
        navigationController.pushViewController(screenPhotosVC, animated: true)
    }
    
    func showLivePhotos() {
        let livePhotosVC = LivePhotosViewController()
        navigationController.pushViewController(livePhotosVC, animated: true)
    }
    
    func showScreenRecordings() {
        let screenRecordingsVC = ScreenRecordingsViewController()
        navigationController.pushViewController(screenRecordingsVC, animated: true)
    }
}
