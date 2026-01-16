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
        viewModel.onMediaGroupTapped = { [weak self] in
            self?.showVideoCompressor()
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
}
