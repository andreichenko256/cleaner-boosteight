import UIKit
import SnapKit

final class OnboardingView: MainCommonView {
    let continueButton = PrimaryButton(title: "Continue")
    let pageControl = PageControlView()
    
    let containerView = {
        $0.clipsToBounds = true
        return $0
    }(UIView())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingView {
    func setupConstraints() {
        [continueButton, pageControl, containerView].forEach {
            addSubview($0)
        }
        
        continueButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeBottom).inset(16)
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(continueButton.snp.top).offset(-24)
        }
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.top.equalToSuperview()
            $0.bottom.equalTo(pageControl.snp.top).offset(-24)
        }
    }
}
