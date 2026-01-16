import UIKit
import SnapKit

final class VideoCompressorCell: UICollectionViewCell {
    static let reuseIdentifier = "VideoCompressorCell"
    
    private let iconImageView = {
        $0.contentMode = .scaleAspectFill
        return $0
    }(UIImageView())
    
    private let sizeLabel = {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = Fonts.Montserrat.regular14
        return $0
    }(UILabel())
    
    private lazy var sizeContainerView = {
        $0.addSubview(sizeLabel)
        sizeLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(3.5)
            make.horizontalEdges.equalToSuperview().inset(4)
        }
        $0.backgroundColor = Colors.primaryBlue
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        return $0
    }(UIView())
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VideoCompressorCell {
    func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    func setupConstraints() {
        [iconImageView, sizeContainerView].forEach {
            contentView.addSubview($0)
        }
        
        iconImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        sizeContainerView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8)
        }
    }
}

extension VideoCompressorCell {
    func configure() {
        
    }
}
