import UIKit
import SnapKit
import Combine

final class OnboardingViewController: UIViewController {
    private var pages: [UIViewController] = []
    private var pageModels: [OnboardingPageModel] = []
    private var cancellables: Set<AnyCancellable> = []
    private let hapticService: HapticServiceProtocol
    private let viewModel: OnboardingViewModel

    private var currentPageIndex: Int = 0
    
    private var onboardingView: OnboardingView {
        return view as! OnboardingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        createPages()
        setupActions()
        setupInitialPage()
    }
    
    init(
        viewModel: OnboardingViewModel = OnboardingViewModel(),
        hapticService: HapticServiceProtocol = HapticService()
    ) {
        self.viewModel = viewModel
        self.hapticService = hapticService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = OnboardingView()
    }
}

private extension OnboardingViewController {
    func setupInitialPage() {
        guard let firstPage = pages.first else { return }
        
        addChild(firstPage)
        onboardingView.containerView.addSubview(firstPage.view)
        
        firstPage.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        firstPage.didMove(toParent: self)
    }
    
    func createPages() {
        pageModels = OnboardingFactory.make()
        pages = pageModels.enumerated().map { index, model in
            let viewController = OnboardingPageViewController()
            
            viewController.configure(with: model)
            return viewController
        }
    }
}

private extension OnboardingViewController {
    func bindViewModel() {
        viewModel.$currentPageIndex
            .sink { [weak self] in
                self?.onboardingView.pageControl.currentPage = $0
            }
            .store(in: &cancellables)
        
        onboardingView.pageControl.numberOfPages = viewModel.numberOfPages
    }
}

private extension OnboardingViewController {
    func setupActions() {
        continueButtonTapped()
    }
    
    func continueButtonTapped() {
        onboardingView.continueButton.onTap = { [weak self] in
            guard let self else { return }
            hapticService.impact(.medium)
            if viewModel.isLastPage {
                viewModel.continueButtonTapped()
            } else {
                moveToNextPage()
            }
            
        }
    }
    
    func moveToNextPage() {
        let nextIndex = currentPageIndex + 1
        guard nextIndex < pages.count else { return }
        
        let currentVC = pages[currentPageIndex]
        let nextVC = pages[nextIndex]
        
        transitionWithFade(from: currentVC, to: nextVC) { [weak self] in
            self?.currentPageIndex = nextIndex
            self?.viewModel.continueButtonTapped()
        }
    }
    
    func transitionWithFade(from currentVC: UIViewController, to nextVC: UIViewController, completion: @escaping VoidBlock) {
        addChild(nextVC)
        onboardingView.containerView.addSubview(nextVC.view)
        
        nextVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nextVC.view.alpha = 0
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                currentVC.view.alpha = 0
                nextVC.view.alpha = 1
            },
            completion: { _ in
                currentVC.view.removeFromSuperview()
                currentVC.removeFromParent()
                nextVC.didMove(toParent: self)
                currentVC.view.alpha = 1
                completion()
            }
        )
    }
}
