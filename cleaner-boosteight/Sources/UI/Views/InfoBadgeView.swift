import UIKit
import SnapKit

final class InfoBadgeView: UIView {
    
    private let iconImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    private let titleLabel = {
        $0.numberOfLines = 0
        $0.textColor = Colors.midGray
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(title: String, icon: UIImage) {
        super.init(frame: .zero)
        titleLabel.text = title
        iconImageView.image = icon
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InfoBadgeView {
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
}

private extension InfoBadgeView {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        
        setupShadow()
    }
    
    func setupConstraints() {
        [iconImageView, titleLabel].forEach {
            addSubview($0)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.verticalEdges.equalToSuperview().inset(7.5)
        }
    }
    
    func setupShadow() {
        layer.shadowColor = Colors.primaryBlack.cgColor
        layer.shadowOpacity = 0.22
        layer.shadowRadius = 4.9 / 2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        layer.masksToBounds = false
    }
}
