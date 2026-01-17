import UIKit
import SnapKit
import Photos

final class BestCell: UICollectionViewCell {
    static let reuseIdentifier = "BestCell"
    
    private static let thumbnailCache = NSCache<NSString, UIImage>()
    
    private var currentAsset: PHAsset?
    private var representedAssetIdentifier: String?
    private var currentRequestID: PHImageRequestID?
    private var photoFetchService: PhotoFetchServiceProtocol?
    
    private let previewImageView = {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .systemGray5
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
            $0.trailing.equalTo(label.snp.leading).offset(-2)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if let requestID = currentRequestID {
            PHImageManager.default().cancelImageRequest(requestID)
            currentRequestID = nil
        }
        
        representedAssetIdentifier = nil
        currentAsset = nil
        bestView.isHidden = true
        checkMarkImageView.image = .uncheckedMarkSquare
    }
}

extension BestCell {
    func configure(with asset: PHAsset, isBest: Bool = false, isSelected: Bool = false, photoFetchService: PhotoFetchServiceProtocol) {
        self.currentAsset = asset
        self.photoFetchService = photoFetchService
        self.representedAssetIdentifier = asset.localIdentifier
        bestView.isHidden = !isBest
        checkMarkImageView.image = isSelected ? .checkmarkSquare : .uncheckedMarkSquare
        
        let cacheKey = asset.localIdentifier as NSString
        
        if let cachedImage = Self.thumbnailCache.object(forKey: cacheKey) {
            previewImageView.image = cachedImage
        } else {
            previewImageView.image = nil
            loadThumbnail(for: asset)
        }
    }

    private func loadThumbnail(for asset: PHAsset) {
        let assetIdentifier = asset.localIdentifier
        
        guard assetIdentifier == representedAssetIdentifier else {
            return
        }
        
        let cacheKey = assetIdentifier as NSString
        let targetSize = CGSize(width: 176 * UIScreen.main.scale, height: 176 * UIScreen.main.scale)
        
        Task {
            guard let photoFetchService = self.photoFetchService,
                  assetIdentifier == self.representedAssetIdentifier else {
                return
            }
            
            if let thumbnail = await photoFetchService.requestThumbnail(for: asset, targetSize: targetSize) {
                Self.thumbnailCache.setObject(thumbnail, forKey: cacheKey)
                
                await MainActor.run {
                    guard assetIdentifier == self.representedAssetIdentifier else {
                        return
                    }
                    self.previewImageView.image = thumbnail
                }
            }
        }
    }
    
    func updateSelection(isSelected: Bool) {
        checkMarkImageView.image = isSelected ? .checkmarkSquare : .uncheckedMarkSquare
    }

}

private extension BestCell {
    func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        clipsToBounds = true
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
