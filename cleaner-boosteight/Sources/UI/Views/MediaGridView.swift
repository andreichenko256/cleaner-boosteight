import UIKit
import SnapKit

final class MediaGridView: MainCommonView, CustomNavigationBarConfigurable {
    lazy var customNavigationBar = CustomNavigationBar(title: title)
    
    let countInfoBadge = InfoBadgeView(title: "0", icon: .videoBadge)
    let sizeInfoBadge = InfoBadgeView(title: "0", icon: .storageBadge)
    let selectionView = SelectionView()
    
    let deleteItemsButton = {
        $0.isHidden = true
        return $0
    }(PrimaryButton(title: "Delete"))
    
    let collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 177, height: 216)
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(SelectableItemCell.self, forCellWithReuseIdentifier: SelectableItemCell.reuseIdentifier)
        
        return collectionView
    }()
    
    private let title: String
    
    private let loadingIndicator = {
        $0.style = .large
        $0.hidesWhenStopped = true
        $0.color = .black
        return $0
    }(UIActivityIndicatorView())
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        setupCustomNavigationBar()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showLoading() {
        loadingIndicator.startAnimating()
        collectionView.alpha = 0.5
        collectionView.isUserInteractionEnabled = false
        countInfoBadge.alpha = 0.5
        sizeInfoBadge.alpha = 0.5
        selectionView.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        collectionView.alpha = 1.0
        collectionView.isUserInteractionEnabled = true
        countInfoBadge.alpha = 1.0
        sizeInfoBadge.alpha = 1.0
        selectionView.isUserInteractionEnabled = true
    }
    
    func showEmptyState() {
        collectionView.isHidden = true
        countInfoBadge.isHidden = true
        sizeInfoBadge.isHidden = true
        selectionView.isHidden = true
    }
    
    func hideEmptyState() {
        collectionView.isHidden = false
        countInfoBadge.isHidden = false
        sizeInfoBadge.isHidden = false
        selectionView.isHidden = false
    }
}

private extension MediaGridView {
    func setupConstraints() {
        [countInfoBadge,
         sizeInfoBadge,
         selectionView,
         collectionView,
         deleteItemsButton,
         loadingIndicator].forEach {
            addSubview($0)
        }
        
        countInfoBadge.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(16)
        }
        
        sizeInfoBadge.snp.makeConstraints {
            $0.top.equalTo(countInfoBadge)
            $0.leading.equalTo(countInfoBadge.snp.trailing).offset(8)
        }
        
        selectionView.snp.makeConstraints {
            $0.top.equalTo(safeTop).inset(13)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(sizeInfoBadge.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        
        deleteItemsButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeBottom).inset(16)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        bringSubviewToFront(loadingIndicator)
        bringSubviewToFront(selectionView)
        bringSubviewToFront(deleteItemsButton)
    }
}
