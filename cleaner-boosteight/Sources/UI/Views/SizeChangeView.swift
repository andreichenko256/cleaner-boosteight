import UIKit
import SnapKit

final class SizeChangeView: UIView {
    
    let nowValueLabel = {
        $0.text = "-"
        $0.textColor = Colors.primaryBlack
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    let willBeValueLabel = {
        $0.text = "-"
        $0.textColor = Colors.primaryBlue
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let nowLabel = createTitleLabel(title: "Now")
    private let willBeLabel = createTitleLabel(title: "Will be")
    
    private let arrowImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView(image: .arrowUp2))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SizeChangeView {
    func setupConstraints() {
        [nowLabel, willBeLabel, arrowImageView,
         nowValueLabel, willBeValueLabel].forEach {
            addSubview($0)
        }
        
        nowLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalTo(nowValueLabel)
        }
        
        willBeLabel.snp.makeConstraints {
            $0.top.equalTo(nowLabel)
            $0.centerX.equalTo(willBeValueLabel)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        nowValueLabel.snp.makeConstraints {
            $0.top.equalTo(nowLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(6.5)
            $0.bottom.equalToSuperview()
        }
        
        willBeValueLabel.snp.makeConstraints {
            $0.top.equalTo(willBeLabel.snp.bottom).offset(6)
            $0.trailing.equalToSuperview().inset(6.5)
            $0.bottom.equalToSuperview()
        }
    }
    
    static func createTitleLabel(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        label.textColor = Colors.primaryGray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }
}

extension SizeChangeView {
    func updateSizes(now: String, willBe: String) {
        nowValueLabel.text = now
        willBeValueLabel.text = willBe
    }
}
