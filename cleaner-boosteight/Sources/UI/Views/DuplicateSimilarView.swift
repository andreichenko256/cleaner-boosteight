import UIKit
import SnapKit

enum DuplicateSimilarViewType {
    case duplicate
    case similar
}

final class DuplicateSimilarView: MainCommonView, CustomNavigationBarConfigurable {
    let countInfoBadge = InfoBadgeView(title: "0", icon: .videoBadge)
    let sizeInfoBadge = InfoBadgeView(title: "0", icon: .storageBadge)
    let selectionView = SelectionView()
    let deleteButton = {
        $0.isHidden = true
        return $0
    }(PrimaryButton(title: "Delete"))
    
    lazy var customNavigationBar = CustomNavigationBar(title: title)
    
    let tableView: UITableView = {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = true
        $0.register(DuplicateSimilarCell.self, forCellReuseIdentifier: DuplicateSimilarCell.reuseIdentifier)
        return $0
    }(UITableView())
    
    private let loadingIndicator = {
        $0.style = .large
        $0.hidesWhenStopped = true
        $0.color = .black
        return $0
    }(UIActivityIndicatorView())
    
    private let title: String

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
        
        setupCustomNavigationBar()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension DuplicateSimilarView {
    func setupConstraints() {
        [countInfoBadge, sizeInfoBadge, selectionView,
         tableView, deleteButton, loadingIndicator].forEach {
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
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(sizeInfoBadge.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeBottom).inset(16)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        bringSubviewToFront(selectionView)
    }
}

extension DuplicateSimilarView {
    func showLoading() {
        loadingIndicator.startAnimating()
        tableView.alpha = 0.5
        tableView.isUserInteractionEnabled = false
        countInfoBadge.alpha = 0.5
        sizeInfoBadge.alpha = 0.5
        selectionView.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        tableView.alpha = 1.0
        tableView.isUserInteractionEnabled = true
        countInfoBadge.alpha = 1.0
        sizeInfoBadge.alpha = 1.0
        selectionView.isUserInteractionEnabled = true
    }
}
