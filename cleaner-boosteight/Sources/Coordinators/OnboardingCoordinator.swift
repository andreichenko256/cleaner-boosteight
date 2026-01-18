import UIKit

final class OnboardingCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var onFinish: VoidBlock?
    
    let navigationController: UINavigationController
    
    private let onboardingService: OnboardingServiceProtocol
    
    init(
        navigationController: UINavigationController,
        onboardingService: OnboardingServiceProtocol = OnboardingService()
    ) {
        self.navigationController = navigationController
        self.onboardingService = onboardingService
    }
    
    func start() {
        let viewModel = OnboardingViewModel()
        viewModel.onOnboardingComplete = { [weak self] in
            self?.finish()
        }
        
        let onboardingVC = OnboardingViewController(viewModel: viewModel)
        navigationController.setViewControllers([onboardingVC], animated: true)
    }
    
    func finish() {
        onboardingService.markOnboardingAsCompleted()
        onFinish?()
    }
}
