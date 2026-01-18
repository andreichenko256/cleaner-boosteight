import UIKit
import SnapKit
import Combine
import Photos

final class ScreenRecordingsViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private var sizeCalculationTask: Task<Void, Never>?
    
    private var screenRecordingsView: MediaGridView {
        return view as! MediaGridView
    }
    
    private let thumbnailCache = NSCache<NSString, UIImage>()
    private let photoFetchService = PhotoFetchService()
    private let viewModel: ScreenRecordingsViewModel
    
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
        view = MediaGridView(title: "Screen Recordings")
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

extension ScreenRecordingsViewController: UICollectionViewDelegateFlowLayout {
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
        screenRecordingsView.gradientOverlay.isHidden = !hasSelection
        screenRecordingsView.selectionView.updateSelectionState(hasSelectedItems: hasSelection)
        
        if hasSelection {
            let selectedCount = viewModel.selectedCount
            let recordingText = selectedCount == 1 ? "recording" : "recordings"
            screenRecordingsView.deleteItemsButton.setTitle(
                "Delete \(selectedCount) \(recordingText)",
                for: .normal
            )
            
            sizeCalculationTask?.cancel()
            
            sizeCalculationTask = Task { [weak self] in
                guard let self = self else { return }
                let currentCount = selectedCount
                
                let size = await calculateSizeAsync()
                
                guard !Task.isCancelled else { return }
                
                let sizeFormatted = self.formatSizeInMB(size)
                
                await MainActor.run {
                    guard !Task.isCancelled,
                          currentCount == self.viewModel.selectedCount else {
                        return
                    }
                    let recordingText = currentCount == 1 ? "recording" : "recordings"
                    self.screenRecordingsView.deleteItemsButton.setTitle(
                        "Delete \(currentCount) \(recordingText) (\(sizeFormatted))",
                        for: .normal
                    )
                }
            }
        }
    }
    
    func calculateSizeAsync() async -> UInt64 {
        let selectedItems = viewModel.selectedItems
        var totalSize: UInt64 = 0
        let batchSize = 5
        
        for (index, item) in selectedItems.enumerated() {
            if Task.isCancelled {
                return totalSize
            }
            
            let assetSize = await Task.detached(priority: .utility) {
                let resources = PHAssetResource.assetResources(for: item.asset)
                var size: UInt64 = 0
                for resource in resources {
                    if let fileSize = resource.value(forKey: "fileSize") as? UInt64 {
                        size += fileSize
                    }
                }
                return size
            }.value
            
            totalSize += assetSize
            
            if (index + 1) % batchSize == 0 {
                await Task.yield()
            }
        }
        
        return totalSize
    }
    
    private func formatSizeInMB(_ bytes: UInt64) -> String {
        let mb = Double(bytes) / 1_048_576.0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.decimalSeparator = ","
        numberFormatter.groupingSeparator = ""
        
        guard let formattedNumber = numberFormatter.string(from: NSNumber(value: mb)) else {
            return String(format: "%.1f MB", mb).replacingOccurrences(of: ".", with: ",")
        }
        
        return "\(formattedNumber) MB"
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
