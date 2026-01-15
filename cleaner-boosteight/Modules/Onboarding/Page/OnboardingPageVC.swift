import UIKit
import SnapKit

final class OnboardingPageViewController: UIViewController {
    var isLastPage = false
    
    private var onboardingPageView: OnboardingPageView {
        return view as! OnboardingPageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        view = OnboardingPageView()
    }
}

extension OnboardingPageViewController {
    func configure(with onboardingModel: OnboardingPageModel) {
        onboardingPageView.titleLabel.text = onboardingModel.title
        onboardingPageView.descriptionLabel.text = onboardingModel.description
//        onboardingPageView.imageView.image = onboardingModel.image
    }
}


