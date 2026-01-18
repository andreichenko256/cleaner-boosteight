import UIKit
import Photos

final class VideoCompressorCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onFinish: VoidBlock?
    
    let navigationController: UINavigationController
    
    private weak var videoCompressorViewController: VideoCompressorViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let videoCompressorVC = VideoCompressorViewController()
        self.videoCompressorViewController = videoCompressorVC
        videoCompressorVC.onBack = { [weak self] in
            self?.finish()
        }
        
        videoCompressorVC.onVideoSelected = { [weak self] video in
            self?.showSelectVideoQuality(for: video)
        }
        
        navigationController.pushViewController(videoCompressorVC, animated: true)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
        onFinish?()
    }
}

private extension VideoCompressorCoordinator {
    func showSelectVideoQuality(for video: VideoModel) {
        let viewModel = SelectVideoQualityViewModel(videoModel: video)
        let selectVideoQualityVC = SelectVideoQualityViewController(viewModel: viewModel)
        
        selectVideoQualityVC.onBack = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        selectVideoQualityVC.onCompress = { [weak self] asset, quality in
            self?.showCompressingVideo(asset: asset, quality: quality, originalSize: viewModel.originalSize)
        }
        
        navigationController.pushViewController(selectVideoQualityVC, animated: true)
    }
    
    func showCompressingVideo(asset: PHAsset, quality: VideoQuality, originalSize: UInt64) {
        let viewModel = CompressingVideoViewModel(videoAsset: asset, quality: quality)
        let compressingVC = CompressingVideoViewController(viewModel: viewModel)
        
        compressingVC.onCancel = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        
        compressingVC.onCompletion = { [weak self] compressedURL in
            self?.showPreviewAfterCompress(
                originalAsset: asset,
                originalSize: originalSize,
                compressedURL: compressedURL
            )
        }
        
        navigationController.pushViewController(compressingVC, animated: true)
    }
    
    func showPreviewAfterCompress(originalAsset: PHAsset, originalSize: UInt64, compressedURL: URL) {
        let viewModel = PreviewAfterCompressViewModel(
            originalVideoAsset: originalAsset,
            originalSizeBytes: originalSize,
            compressedVideoURL: compressedURL
        )
        let previewVC = PreviewAfterCompressViewController(viewModel: viewModel)
        
        previewVC.onBack = { [weak self] in
            guard let self = self,
                  let videoCompressorVC = self.videoCompressorViewController else {
                return
            }
            self.navigationController.popToViewController(videoCompressorVC, animated: true)
        }
        
        navigationController.pushViewController(previewVC, animated: true)
    }
}
