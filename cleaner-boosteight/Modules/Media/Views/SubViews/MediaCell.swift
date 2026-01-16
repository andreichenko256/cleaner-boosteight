import UIKit
import SnapKit

final class MediaCell: UICollectionViewCell {
    static let reuseIdentifier = "MediaCell"
    
    private let iconImageView = {
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    
    private let titleLabel = {
        $0.textColor = Colors.mainText
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let countLabel = {
        $0.textColor = Colors.midGray
        $0.font = .systemFont(ofSize: 14, weight: .regular)
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

private extension MediaCell {
    func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        setupShadow()
    }
    
    func setupConstraints() {
        [iconImageView, titleLabel, countLabel].forEach {
            contentView.addSubview($0)
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(13)
            $0.size.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView)
            $0.top.equalTo(iconImageView.snp.bottom).offset(21.4)
        }
        
        countLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView)
            $0.top.equalTo(titleLabel.snp.bottom).offset(6.6)
        }
    }
    
    func setupShadow() {
        layer.shadowColor = Colors.primaryBlack.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8.3 / 2
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.masksToBounds = false
    }
}

extension MediaCell {
    func configure(with model: MediaModel) {
        titleLabel.text = model.title
        countLabel.text = "\(model.count) items"
        iconImageView.image = model.image
    }
}
