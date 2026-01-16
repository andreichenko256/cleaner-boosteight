import UIKit
import SnapKit
import Combine

final class ScreenPhotosViewController: UIViewController {
    private let viewModel: ScreenPhotosViewModel
    private var cancellables = Set<AnyCancellable>()
    private let thumbnailCache = NSCache<NSString, UIImage>()
    private let photoFetchService = PhotoFetchService()
    
    private var screenPhotosView: ScreenPhotosView {
        return view as! ScreenPhotosView
    }
    
    init(viewModel: ScreenPhotosViewModel = ScreenPhotosViewModel()) {
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
        view = ScreenPhotosView()
    }
}

extension ScreenPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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

private extension ScreenPhotosViewController {
    func setupCollectionView() {
        screenPhotosView.collectionView.delegate = self
        screenPhotosView.collectionView.dataSource = self
    }
    
    func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            screenPhotosView.showLoading()
        } else {
            screenPhotosView.hideLoading()
        }
    }
    
    func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            screenPhotosView.showEmptyState()
        } else {
            screenPhotosView.hideEmptyState()
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
                self?.screenPhotosView.collectionView.reloadData()
                self?.updateSelectionUI()
                
                if !self!.viewModel.isLoading {
                    self?.updateEmptyState(isEmpty: items.isEmpty)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$count
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.screenPhotosView.countInfoBadge.updateTitle("\(count)")
            }
            .store(in: &cancellables)
        
        viewModel.$totalSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                self?.screenPhotosView.sizeInfoBadge.updateTitle(size)
            }
            .store(in: &cancellables)
    }
    
    func setupActions() {
        screenPhotosView.customNavigationBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        screenPhotosView.selectionView.onSelectAllTapped = { [weak self] in
            self?.viewModel.selectAll()
        }
        
        screenPhotosView.selectionView.onDeselectAllTapped = { [weak self] in
            self?.viewModel.deselectAll()
        }
        
        screenPhotosView.deleteItemsButton.addTarget(
            self,
            action: #selector(deleteButtonTapped),
            for: .touchUpInside
        )
    }
    
    func updateSelectionUI() {
        let hasSelection = viewModel.selectedCount > 0
        screenPhotosView.deleteItemsButton.isHidden = !hasSelection
        screenPhotosView.selectionView.updateSelectionState(hasSelectedItems: hasSelection)
        
        if hasSelection {
            screenPhotosView.deleteItemsButton.setTitle(
                "Delete (\(viewModel.selectedCount))",
                for: .normal
            )
        }
    }
    
    @objc func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete Screenshots",
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
