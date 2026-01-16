import UIKit
import SnapKit

final class MediaView: MainCommonView, CustomNavigationBarConfigurable {
    let customNavigationBar = CustomNavigationBar(title: "Media")
    
    let mediaCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.itemSize = CGSize(width: 176, height: 130)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MediaCell.self, forCellWithReuseIdentifier: MediaCell.reuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset.top = 8
        collectionView.contentInset.left = 16.7
        collectionView.contentInset.right = 16.7
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupCustomNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MediaView {
    func setupConstraints() {
        [customNavigationBar, mediaCollectionView].forEach {
            addSubview($0)
        }
        
        mediaCollectionView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
        }
    }
}
