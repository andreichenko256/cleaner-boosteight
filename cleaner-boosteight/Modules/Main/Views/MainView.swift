import UIKit
import SnapKit

final class MainView: UIView {
    let circularProgressView = CircularProgressView()
    
    let valueStorageLabel = {
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    let mediaTableView = {
        $0.showsVerticalScrollIndicator = false
        $0.separatorStyle = .none
        $0.alwaysBounceVertical = false
        $0.isScrollEnabled = true
        $0.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        $0.scrollIndicatorInsets = $0.contentInset
        $0.register(MediaGroupCell.self, forCellReuseIdentifier: MediaGroupCell.reuseIdentifier)
        return $0
    }(UITableView())
    
    private let iphoneStorageLabel = {
        $0.text = "iPhone Storage"
        $0.textColor = Colors.primaryWhite
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.numberOfLines = 0
        return $0
    }(UILabel())
    
    private let containerView = {
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = [
             .layerMinXMinYCorner,
             .layerMaxXMinYCorner
         ]
        return $0
    }(UIView())

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MainView {
    func setupUI() {
        backgroundColor = Colors.secondaryBlue
    }
    
    func setupConstraints() {
        [iphoneStorageLabel, valueStorageLabel,
         circularProgressView, containerView].forEach {
            addSubview($0)
        }
        
        iphoneStorageLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12.5)
            $0.top.equalTo(safeTop).inset(82.5)
        }
        
        valueStorageLabel.snp.makeConstraints {
            $0.leading.equalTo(iphoneStorageLabel)
            $0.top.equalTo(iphoneStorageLabel.snp.bottom).offset(6)
        }
        
        circularProgressView.snp.makeConstraints {
            $0.top.equalTo(safeTop).inset(30.5)
            $0.trailing.equalToSuperview().inset(37)
            $0.size.equalTo(148)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(circularProgressView.snp.bottom).offset(UIDevice.hasHomeButton ? 30 : 47.5)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        setupContainerViewConstraints()
    }
    
    func setupContainerViewConstraints() {
        [mediaTableView].forEach {
            containerView.addSubview($0)
        }
 
        mediaTableView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeBottom)
        }
    }
}
