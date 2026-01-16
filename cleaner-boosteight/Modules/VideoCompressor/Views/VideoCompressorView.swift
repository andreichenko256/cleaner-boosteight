import UIKit
import SnapKit

final class VideoCompressorView: MainCommonView, CustomNavigationBarConfigurable {
    let customNavigationBar = CustomNavigationBar(title: "Video Compressor")
    
    private let videoInfoBadge = InfoBadgeView(title: "1746 Videos", icon: .videoBadge)
    
    let videosCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 176, height: 176)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 24
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(VideoCompressorCell.self, forCellWithReuseIdentifier: VideoCompressorCell.reuseIdentifier)
        collectionView.contentInset.top = 16
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCustomNavigationBar()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension VideoCompressorView {
    func setupConstraints() {
        [videoInfoBadge, videosCollectionView].forEach {
            addSubview($0)
        }
        
        videoInfoBadge.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(8)
        }
        
        videosCollectionView.snp.makeConstraints {
            $0.top.equalTo(videoInfoBadge.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
    }
}
