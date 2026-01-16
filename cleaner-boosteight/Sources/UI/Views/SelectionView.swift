import UIKit
import SnapKit

final class SelectionView: UIView {
    
    private let checkMarkImageView = {
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        return $0
    }(UIImageView(image: .checkmarkBlack))
    
    private let titleLabel = {
        $0.text = "Select all"
        $0.textColor = Colors.primaryBlack
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SelectionView {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 5
        setupShadow()
    }
    
    func setupConstraints() {
        [checkMarkImageView, titleLabel].forEach {
            addSubview($0)
        }
        
        checkMarkImageView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(3)
            $0.leading.equalToSuperview().inset(8)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(checkMarkImageView.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setupShadow() {
        layer.shadowColor = Colors.primaryBlack.cgColor
        layer.shadowOpacity = 0.22
        layer.shadowRadius = 4.9 / 2
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
        layer.masksToBounds = false
    }
}
