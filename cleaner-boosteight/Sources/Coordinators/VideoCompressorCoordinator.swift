import UIKit

final class VideoCompressorCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onFinish: VoidBlock?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let videoCompressorVC = VideoCompressorViewController()
        videoCompressorVC.onBack = { [weak self] in
            self?.finish()
        }
        
        navigationController.pushViewController(videoCompressorVC, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
        onFinish?()
    }
}
