import UIKit
import SnapKit

final class ScreenRecordingsView: MainCommonView, CustomNavigationBarConfigurable {
    let customNavigationBar = CustomNavigationBar(title: "Screen Recordings")
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        setupCustomNavigationBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ScreenRecordingsView {
    func setupConstraints() {
        [customNavigationBar, countInfoBadge,
         sizeInfoBadge, selectionView,
         collectionView, deleteItemsButton].forEach {
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
    }
}
