import UIKit
import Photos

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        
//        let coordinator = AppCoordinator(window: window)
//        coordinator.start()
        
        // Временно для тестирования - получаем первое видео
        let videoFetchService = VideoFetchService()
        Task {
            let videos = await videoFetchService.fetchAllVideos()
            if let firstVideo = videos.first {
                let viewModel = SelectVideoQualityViewModel(videoModel: firstVideo)
                let viewController = SelectVideoQualityViewController(viewModel: viewModel)
                await MainActor.run {
                    window.rootViewController = viewController
                }
            }
        }
        
        self.window = window
        window.makeKeyAndVisible()
//        self.appCoordinator = coordinator
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
}

