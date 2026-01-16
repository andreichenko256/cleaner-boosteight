import UIKit
import SnapKit

final class VideoCompressorCell: UICollectionViewCell {
    static let reuseIdentifier = "VideoCompressorCell"
    
    private let thumbnailImageView = {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = Colors.secondaryGray.withAlphaComponent(0.5)
        return $0
    }(UIImageView())
    
    private let sizeLabel = {
        $0.numberOfLines = 1
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        sizeLabel.text = nil
    }
}

private extension VideoCompressorCell {
    func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    func setupConstraints() {
        [thumbnailImageView, sizeContainerView].forEach {
            contentView.addSubview($0)
        }
        
        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        sizeContainerView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(8)
        }
    }
}

extension VideoCompressorCell {
    func configure(with video: VideoModel) {
        sizeLabel.text = video.formattedSize
    }
    
    func updateThumbnail(_ image: UIImage?) {
        thumbnailImageView.image = image
    }
}
