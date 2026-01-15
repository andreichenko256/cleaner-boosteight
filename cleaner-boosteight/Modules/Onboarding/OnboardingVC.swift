import UIKit
import SnapKit
import Combine

final class OnboardingViewController: UIViewController {
    private var pages: [UIViewController] = []
    private var pageModels: [OnboardingPageModel] = []
    
    private let viewModel = OnboardingViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private let pageVC = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    private var onboardingView: OnboardingView {
        return view as! OnboardingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        createPages()
        setupActions()
        setupPageVC()
    }
    
    override func loadView() {
        view = OnboardingView()
    }
}

private extension OnboardingViewController {
    func setupPageVC() {
        onboardingView.containerView.addSubview(pageVC.view)
        
        pageVC.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addChild(pageVC)
        
        if let firstPage = pages.first {
            pageVC.setViewControllers(
                [firstPage],
                direction: .forward,
                animated: true,
                completion: nil
            )
        }
        
        pageVC.didMove(toParent: self)
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
            if viewModel.isLastPage {
                viewModel.continueButtonTapped()
            } else {
                moveToNextPage()
            }

        }
    }
    
    func moveToNextPage() {
           guard let nextVC = viewModel.getViewController(at: viewModel.currentPageIndex + 1) else {
               return
           }
           
           pageVC.setViewControllers(
               [nextVC],
               direction: .forward,
               animated: true
           ) { [weak self] _ in
               self?.viewModel.continueButtonTapped()
           }
       }
}
