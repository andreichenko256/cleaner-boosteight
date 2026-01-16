import Combine
import UIKit

final class OnboardingViewModel {
    @Published private(set) var currentPageIndex: Int = 0
    @Published private(set) var isLastPage: Bool = false
    
    private(set) var pages: [OnboardingPageModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    var numberOfPages: Int {
        pages.count
    }
    
    var onOnboardingComplete: VoidBlock?
    
    init() {
        setupPages()
        setupObservers()
    }
}

private extension OnboardingViewModel {
    func setupPages() {
        pages = OnboardingFactory.make()
    }
    
    private func setupObservers() {
        $currentPageIndex
            .map { [weak self] index in
                guard let self = self else { return false }
                return index == self.pages.count - 1
            }
            .assign(to: &$isLastPage)
    }
    
    func moveToNextPage() {
        guard currentPageIndex < pages.count - 1 else { return }
        currentPageIndex += 1
    }
    
    func finishOnboarding() {
        onOnboardingComplete?()
    }
}

extension OnboardingViewModel {
    func continueButtonTapped() {
        if isLastPage {
            finishOnboarding()
        } else {
            moveToNextPage()
        }
    }
    
    func pageDidChange(to index: Int) {
        currentPageIndex = index
    }
    
    func getViewController(at index: Int) -> OnboardingPageViewController? {
        guard index >= 0 && index < pages.count else { return nil }
        
        let viewController = OnboardingPageViewController()
        viewController.configure(with: pages[index])
        return viewController
    }
}
