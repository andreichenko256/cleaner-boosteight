import UIKit
import SnapKit
import Photos

final class DuplicateSimilarCell: UITableViewCell {
    static let reuseIdentifier = "DuplicateSimilarCell"
    private var assets: [PHAsset] = []
    
    private let containerView = UIView()
    
    private let countLabel = {
        $0.numberOfLines = 0
        $0.textColor = Colors.primaryBlack
        $0.font = .systemFont(ofSize: 16, weight: .semibold)
        return $0
    }(UILabel())
    
    private let collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8.05
        layout.itemSize = CGSize(width: 176, height: 176)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        collectionView.register(BestCell.self, forCellWithReuseIdentifier: BestCell.reuseIdentifier)
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DuplicateSimilarCell {
    func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    func setupConstraints() {
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
        
        [countLabel].forEach {
            containerView.addSubview($0)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
        }
    }
}

extension DuplicateSimilarCell: UICollectionViewDelegate, UICollectionViewDataSource {
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BestCell.reuseIdentifier, for: indexPath) as! BestCell
        
        return cell
    }
}
