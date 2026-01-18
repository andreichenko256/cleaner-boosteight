import UIKit
import SnapKit
import Combine
import Photos

final class SimilarPhotosViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
    private var groupSelectionStates: [String: Set<String>] = [:]
    private var sizeCalculationTask: Task<Void, Never>?
    
    private var duplicateSimilarView: DuplicateSimilarView {
        return view as! DuplicateSimilarView
    }
    private let photoFetchService = PhotoFetchService()
    private let viewModel: SimilarPhotosViewModel
    
    init(viewModel: SimilarPhotosViewModel = SimilarPhotosViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupBindings()
        setupActions()
        viewModel.loadData()
    }
    
    override func loadView() {
        view = DuplicateSimilarView(title: "Similar Photos")
    }
}

extension SimilarPhotosViewController: UITableViewDelegate, UITableViewDataSource {
    private func setupTableView() {
        duplicateSimilarView.tableView.dataSource = self
        duplicateSimilarView.tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.similarGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DuplicateSimilarCell.reuseIdentifier, for: indexPath) as! DuplicateSimilarCell
        
        guard indexPath.row < viewModel.similarGroups.count else {
            return cell
        }
        
        let group = viewModel.similarGroups[indexPath.row]
        let groupId = group.first?.localIdentifier ?? ""
        let similarCount = group.count - 1
        let selectionState = groupSelectionStates[groupId] ?? Set<String>()
        cell.configure(
            with: group,
            count: similarCount,
            photoFetchService: photoFetchService,
            selectedAssetIdentifiers: selectionState,
            onSelectionChanged:  { [weak self] assetIdentifier, isSelected in
                guard let self = self else { return }
                if isSelected {
                    self.groupSelectionStates[groupId]?.insert(assetIdentifier)
                } else {
                    self.groupSelectionStates[groupId]?.remove(assetIdentifier)
                }
                self.updateSelectionUI()
            }, suffixText: "Similar")
        
        return cell
    }
}

private extension SimilarPhotosViewController {
    func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            duplicateSimilarView.showLoading()
        } else {
            duplicateSimilarView.hideLoading()
        }
    }
    
    func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$similarGroups
            .receive(on: DispatchQueue.main)
            .sink { [weak self] groups in
                self?.initializeSelectionStates(for: groups)
                self?.duplicateSimilarView.tableView.reloadData()
                self?.updateSelectionUI()
            }
            .store(in: &cancellables)
        
        viewModel.$count
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.duplicateSimilarView.countInfoBadge.updateTitle("\(count)")
            }
            .store(in: &cancellables)
        
        viewModel.$totalSize
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                self?.duplicateSimilarView.sizeInfoBadge.updateTitle(size)
            }
            .store(in: &cancellables)
    }
    
    func initializeSelectionStates(for groups: [[PHAsset]]) {
        groupSelectionStates.removeAll()
        
        for group in groups {
            let groupId = group.first?.localIdentifier ?? ""
            guard !groupId.isEmpty else { continue }
            
            var selectedIds = Set<String>()
            
            for (index, asset) in group.enumerated() where index > 0 {
                selectedIds.insert(asset.localIdentifier)
            }
            groupSelectionStates[groupId] = selectedIds
        }
    }
    
    func setupActions() {
        duplicateSimilarView.customNavigationBar.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        duplicateSimilarView.selectionView.onSelectAllTapped = { [weak self] in
            self?.selectAll()
        }
        
        duplicateSimilarView.selectionView.onDeselectAllTapped = { [weak self] in
            self?.deselectAll()
        }
        
        duplicateSimilarView.deleteButton.addTarget(
            self,
            action: #selector(deleteButtonTapped),
            for: .touchUpInside
        )
    }
    
    func selectAll() {
        for group in viewModel.similarGroups {
            let groupId = group.first?.localIdentifier ?? ""
            guard !groupId.isEmpty else { continue }
            
            var selectedIds = Set<String>()
            
            for (index, asset) in group.enumerated() where index > 0 {
                selectedIds.insert(asset.localIdentifier)
            }
            groupSelectionStates[groupId] = selectedIds
        }
        
        reloadVisibleCollectionViews()
        updateSelectionUI()
    }
    
    func deselectAll() {
        for groupId in groupSelectionStates.keys {
            groupSelectionStates[groupId] = Set<String>()
        }
        
        reloadVisibleCollectionViews()
        updateSelectionUI()
    }
    
    func reloadVisibleCollectionViews() {
        for (_, cell) in duplicateSimilarView.tableView.visibleCells.enumerated() {
            if let duplicateCell = cell as? DuplicateSimilarCell,
               let indexPath = duplicateSimilarView.tableView.indexPath(for: cell),
               indexPath.row < viewModel.similarGroups.count {
                
                let group = viewModel.similarGroups[indexPath.row]
                let groupId = group.first?.localIdentifier ?? ""
                let selectionState = groupSelectionStates[groupId] ?? Set<String>()
                
                duplicateCell.updateSelectionState(selectionState)
            }
        }
    }
    
    func updateSelectionUI() {
        let selectedCount = calculateSelectedCount()
        let hasSelection = selectedCount > 0
        
        duplicateSimilarView.deleteButton.isHidden = !hasSelection
        duplicateSimilarView.gradientOverlay.isHidden = !hasSelection
        duplicateSimilarView.selectionView.updateSelectionState(hasSelectedItems: hasSelection)
        
        if hasSelection {
            let photoText = selectedCount == 1 ? "photo" : "photos"
            duplicateSimilarView.deleteButton.setTitle(
                "Delete \(selectedCount) \(photoText)",
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
                          currentCount == self.calculateSelectedCount() else {
                        return
                    }
                    let photoText = currentCount == 1 ? "photo" : "photos"
                    self.duplicateSimilarView.deleteButton.setTitle(
                        "Delete \(currentCount) \(photoText) (\(sizeFormatted))",
                        for: .normal
                    )
                }
            }
        }
    }
    
    func calculateSelectedCount() -> Int {
        var totalCount = 0
        for selectedIds in groupSelectionStates.values {
            totalCount += selectedIds.count
        }
        return totalCount
    }
    
    func getSelectedAssets() -> [PHAsset] {
        var selectedAssets: [PHAsset] = []
        
        for (groupId, selectedIds) in groupSelectionStates {
            guard !selectedIds.isEmpty,
                  let groupIndex = viewModel.similarGroups.firstIndex(where: { $0.first?.localIdentifier == groupId }) else {
                continue
            }
            
            let group = viewModel.similarGroups[groupIndex]
            for asset in group where selectedIds.contains(asset.localIdentifier) {
                selectedAssets.append(asset)
            }
        }
        
        return selectedAssets
    }
    
    func calculateSizeAsync() async -> UInt64 {
        let assets = getSelectedAssets()
        var totalSize: UInt64 = 0
        let batchSize = 5
        
        for (index, asset) in assets.enumerated() {
            if Task.isCancelled {
                return totalSize
            }
            
            let assetSize = await Task.detached(priority: .utility) {
                let resources = PHAssetResource.assetResources(for: asset)
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
    
    func formatSizeInMB(_ bytes: UInt64) -> String {
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
        let selectedCount = calculateSelectedCount()
        
        let alert = UIAlertController(
            title: "Delete Similar Photos",
            message: "Are you sure you want to delete \(selectedCount) item(s)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            Task {
                await self?.deleteSelectedPhotos()
            }
        })
        
        present(alert, animated: true)
    }
    
    func deleteSelectedPhotos() async {
        var assetsToDelete: [PHAsset] = []
        
        for (groupId, selectedIds) in groupSelectionStates {
            guard !selectedIds.isEmpty,
                  let groupIndex = viewModel.similarGroups.firstIndex(where: { $0.first?.localIdentifier == groupId }) else {
                continue
            }
            
            let group = viewModel.similarGroups[groupIndex]
            for asset in group where selectedIds.contains(asset.localIdentifier) {
                assetsToDelete.append(asset)
            }
        }
        
        guard !assetsToDelete.isEmpty else { return }
        
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
            }) { success, error in
                if success {
                    Task {
                        await self.viewModel.refreshData()
                        await MainActor.run {
                            self.groupSelectionStates.removeAll()
                            self.duplicateSimilarView.tableView.reloadData()
                            self.updateSelectionUI()
                            NotificationCenter.default.post(name: .mediaItemsDeleted, object: nil)
                        }
                    }
                }
                continuation.resume()
            }
        }
    }
}
