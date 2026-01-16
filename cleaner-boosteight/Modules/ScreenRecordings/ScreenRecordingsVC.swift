import UIKit
import SnapKit
import Combine

final class ScreenRecordingsViewController: UIViewController {
    private let viewModel: ScreenRecordingsViewModel
    private var cancellables = Set<AnyCancellable>()
    private let thumbnailCache = NSCache<NSString, UIImage>()
    private let photoFetchService = PhotoFetchService()
    
    private var screenRecordingsView: ScreenRecordingsView {
        return view as! ScreenRecordingsView
    }
    
    init(viewModel: ScreenRecordingsViewModel = ScreenRecordingsViewModel()) {
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
        view = ScreenRecordingsView()
    }
}

extension ScreenRecordingsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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

private extension ScreenRecordingsViewController {
    func setupCollectionView() {
        screenRecordingsView.collectionView.delegate = self
        screenRecordingsView.collectionView.dataSource = self
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
                self?.screenRecordingsView.collectionView.reloadData()
                self?.updateSelectionUI()
                
                if !self!.viewModel.isLoading {
                    self?.updateEmptyState(isEmpty: items.isEmpty)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$count
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.screenRecordingsView.countInfoBadge.updateTitle("\(count)")
            }
            .store(in: &cancellables)
        
        viewModel.$totalSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                self?.screenRecordingsView.sizeInfoBadge.updateTitle(size)
            }
            .store(in: &cancellables)
    }
    
    func setupActions() {
        screenRecordingsView.customNavigationBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        screenRecordingsView.selectionView.onSelectAllTapped = { [weak self] in
            self?.viewModel.selectAll()
        }
        
        screenRecordingsView.selectionView.onDeselectAllTapped = { [weak self] in
            self?.viewModel.deselectAll()
        }
        
        screenRecordingsView.deleteItemsButton.addTarget(
            self,
            action: #selector(deleteButtonTapped),
            for: .touchUpInside
        )
    }
    
    func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            screenRecordingsView.showLoading()
        } else {
            screenRecordingsView.hideLoading()
        }
    }
    
    func updateEmptyState(isEmpty: Bool) {
        if isEmpty {
            screenRecordingsView.showEmptyState()
        } else {
            screenRecordingsView.hideEmptyState()
        }
    }
    
    func updateSelectionUI() {
        let hasSelection = viewModel.selectedCount > 0
        screenRecordingsView.deleteItemsButton.isHidden = !hasSelection
        screenRecordingsView.selectionView.updateSelectionState(hasSelectedItems: hasSelection)
        
        if hasSelection {
            screenRecordingsView.deleteItemsButton.setTitle(
                "Delete (\(viewModel.selectedCount))",
                for: .normal
            )
        }
    }
    
    @objc func deleteButtonTapped() {
        let alert = UIAlertController(
            title: "Delete Screen Recordings",
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
