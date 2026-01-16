import UIKit
import SnapKit

final class SelectableItemCell: UICollectionViewCell {
    static let reuseIdentifier = "SelectableItemCell"
    
    private let previewImageView = {
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    
    private let checkmarkImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView(image: .uncheckedMarkSquare))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SelectableItemCell {
    func setupUI() {
        layer.cornerRadius = 10
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    func setupConstraints() {
        [previewImageView, checkmarkImageView].forEach {
            contentView.addSubview($0)
        }
        
        previewImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkmarkImageView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().inset(8)
        }
    }
}

extension SelectableItemCell {
//    func configure(with model:) {
//        
//    }
}
