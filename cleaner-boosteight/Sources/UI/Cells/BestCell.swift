import UIKit
import SnapKit

final class BestCell: UICollectionViewCell {
    static let reuseIdentifier = "BestCell"
    
    private let previewImageView = {
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    
    private let checkMarkImageView = {
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView(image: .uncheckedMarkSquare))
    
    private let bestView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        let label = UILabel()
        label.text = "Best"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = Colors.progressColor
        label.numberOfLines = 0
        
        let imageView = UIImageView(image: .stars)
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.verticalEdges.equalToSuperview().inset(4)
        }
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalTo(label)
        }

        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension BestCell {
    func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 10
    }
    
    func setupConstraints() {
        [previewImageView, checkMarkImageView, bestView].forEach {
            contentView.addSubview($0)
        }
        
        previewImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkMarkImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(7.95)
            $0.bottom.equalToSuperview().inset(11.25)
        }
        
        bestView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(6.05)
            $0.bottom.equalToSuperview().inset(11.25)
        }
    }
}
