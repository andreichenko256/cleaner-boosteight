import UIKit
import SnapKit
import Combine

final class LivePhotosViewController: UIViewController {
    private let viewModel: LivePhotosViewModel
    private var cancellables = Set<AnyCancellable>()
    private let thumbnailCache = NSCache<NSString, UIImage>()
    private let photoFetchService = PhotoFetchService()
    
    private var livePhotosView: MediaGridView {
        return view as! MediaGridView
    }
    
    init(viewModel: LivePhotosViewModel = LivePhotosViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupBindings()
        setupActions()
        viewModel.loadData()
    }
    
    override func loadView() {
        view = MediaGridView(title: "Live Photos")
    }
}

extension LivePhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectableItemCell.reuseIdentifier,
            for: indexPath
        ) as! SelectableItemCell
        
        let item = viewModel.items[indexPath.item]
        let cacheKey = item.id as NSString
        
        if let cachedImage = thumbnailCache.object(forKey: cacheKey) {
            cell.configure(with: cachedImage, isSelected: item.isSelected)
        } else {
            cell.configure(with: nil, isSelected: item.isSelected)
            
            Task {
                let targetSize = CGSize(width: 177 * UIScreen.main.scale, height: 216 * UIScreen.main.scale)
                if let thumbnail = await photoFetchService.requestThumbnail(for: item.asset, targetSize: targetSize) {
                    thumbnailCache.setObject(thumbnail, forKey: cacheKey)
                    
                    if let currentCell = collectionView.cellForItem(at: indexPath) as? SelectableItemCell {
                        currentCell.configure(with: thumbnail, isSelected: item.isSelected)
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.toggleSelection(at: indexPath.item)
    }
}

extension LivePhotosViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalInset: CGFloat = 16
        let interItemSpacing: CGFloat = 8
        let numberOfItemsPerRow: CGFloat = 2
        
        let availableWidth = collectionView.bounds.width - 
            (horizontalInset * 2) - 
            (interItemSpacing * (numberOfItemsPerRow - 1))
        let itemWidth = availableWidth / numberOfItemsPerRow
        
        return CGSize(width: itemWidth, height: itemWidth * (216.0 / 177.0))
    }
}

private extension LivePhotosViewController {
    func setupCollectionView() {
        livePhotosView.collectionView.delegate = self
        livePhotosView.collectionView.dataSource = self
    }
    
    func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            livePhotosView.showLoading()
        } else {
            livePhotosView.hideLoading()
        }
    }
    
    func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            livePhotosView.showEmptyState()
        } else {
            livePhotosView.hideEmptyState()
        }
    }
    
    func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.livePhotosView.collectionView.reloadData()
                self?.updateSelectionUI()
                
                if !self!.viewModel.isLoading {
                    self?.updateEmptyState(isEmpty: items.isEmpty)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$count
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.livePhotosView.countInfoBadge.updateTitle("\(count)")
            }
            .store(in: &cancellables)
        
        viewModel.$totalSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                self?.livePhotosView.sizeInfoBadge.updateTitle(size)
            }
            .store(in: &cancellables)
    }
    
    func setupActions() {
        livePhotosView.customNavigationBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        livePhotosView.selectionView.onSelectAllTapped = { [weak self] in
            self?.viewModel.selectAll()
        }
        
        livePhotosView.selectionView.onDeselectAllTapped = { [weak self] in
            self?.viewModel.deselectAll()
        }
        
        livePhotosView.deleteItemsButton.addTarget(
            self,
            action: #selector(deleteButtonTapped),
            for: .touchUpInside
        )
    }
    
    func updateSelectionUI() {
        let hasSelection = viewModel.selectedCount > 0
        livePhotosView.deleteItemsButton.isHidden = !hasSelection
        livePhotosView.gradientOverlay.isHidden = !hasSelection
        livePhotosView.selectionView.updateSelectionState(hasSelectedItems: hasSelection)
        
        if hasSelection {
            livePhotosView.deleteItemsButton.setTitle(
                "Delete (\(viewModel.selectedCount))",
                for: .normal
            )
        }
    }
    
    @objc func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete Live Photos",
            message: "Are you sure you want to delete \(viewModel.selectedCount) item(s)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            Task {
                await self?.viewModel.deleteSelected()
            }
        })
        
        present(alert, animated: true)
    }
}
