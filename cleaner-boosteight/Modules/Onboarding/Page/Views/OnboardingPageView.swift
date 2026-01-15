import UIKit
import SnapKit

final class OnboardingPageView: UIView {
    
    let titleLabel = {
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.textColor = Colors.primaryBlack
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    let descriptionLabel = {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = Colors.primaryGray
        $0.numberOfLines = 0
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OnboardingPageView {
    func setupConstraints() {
        [descriptionLabel, titleLabel].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-8)
            $0.horizontalEdges.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }
}
