import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController

    private let window: UIWindow
    private let onboardingService: OnboardingServiceProtocol
    
    init(
        window: UIWindow,
        onboardingService: OnboardingServiceProtocol = OnboardingService()
    ) {
        self.window = window
        self.onboardingService = onboardingService
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        setupWindow()
        setupNavigationGestures()
        if shouldShowOnboarding() {
            showOnboarding()
        } else {
            showMainFlow()
        }
    }
    
    func finish() {
    }
}

private extension AppCoordinator {
    func setupWindow() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func shouldShowOnboarding() -> Bool {
        return !onboardingService.hasCompletedOnboarding()
    }
    
    func showOnboarding() {
        let onboardingCoordinator = OnboardingCoordinator(
            navigationController: navigationController,
            onboardingService: onboardingService
        )
        
        onboardingCoordinator.onFinish = { [weak self] in
            self?.removeChild(onboardingCoordinator)
            self?.showMainFlow()
        }
        
        addChild(onboardingCoordinator)
        onboardingCoordinator.start()
    }
    
    func showMainFlow() {
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        
        addChild(mainCoordinator)
        mainCoordinator.start()
    }
    
    func setupNavigationGestures() {
        navigationController.interactivePopGestureRecognizer?.delegate = nil
        navigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
}
