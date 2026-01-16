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
        
        videoCompressorVC.onVideoSelected = { [weak self] video in
            self?.showSelectVideoQuality(for: video)
        }
        
        navigationController.pushViewController(videoCompressorVC, animated: true)
    }
    
    private func showSelectVideoQuality(for video: VideoModel) {
        let viewModel = SelectVideoQualityViewModel(videoModel: video)
        let selectVideoQualityVC = SelectVideoQualityViewController(viewModel: viewModel)
        
        selectVideoQualityVC.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        navigationController.pushViewController(selectVideoQualityVC, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
        onFinish?()
    }
}
