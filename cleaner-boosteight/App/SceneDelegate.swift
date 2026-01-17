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
        window.rootViewController = PreviewAfterCompressViewController()
        window.makeKeyAndVisible()
        self.window = window
//        self.appCoordinator = coordinator
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationCenter.default.post(
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
}

