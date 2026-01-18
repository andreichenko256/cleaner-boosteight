import Combine
import Photos
import Foundation

final class LivePhotosViewModel {
    
    var selectedItems: [PhotoAssetModel] {
        items.filter { $0.isSelected }
    }
    
    var selectedCount: Int {
        selectedItems.count
    }
    
    @Published private(set) var items: [PhotoAssetModel] = []
    @Published private(set) var count: Int = 0
    @Published private(set) var totalSize: String = "0 MB"
    @Published private(set) var isLoading: Bool = false
    
    private let photoFetchService: PhotoFetchServiceProtocol
    private let mediaCountService: MediaCountServiceProtocol

    init(
        photoFetchService: PhotoFetchServiceProtocol = PhotoFetchService(),
        mediaCountService: MediaCountServiceProtocol = MediaCountService()
    ) {
        self.photoFetchService = photoFetchService
        self.mediaCountService = mediaCountService
    }
    
    func loadData() {
        Task {
            await fetchLivePhotos()
        }
    }
    
    func toggleSelection(at index: Int) {
        guard index < items.count else { return }
        items[index].isSelected.toggle()
        items = items
    }
    
    func selectAll() {
        for index in items.indices {
            items[index].isSelected = true
        }
        items = items
    }
    
    func deselectAll() {
        for index in items.indices {
            items[index].isSelected = false
        }
        items = items
    }
    
    func deleteSelected() async {
        let assetsToDelete = selectedItems.map { $0.asset }
        
        guard !assetsToDelete.isEmpty else { return }
        
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(assetsToDelete as NSArray)
            }) { success, error in
                if success {
                    Task {
                        await self.fetchLivePhotos()
                        await MainActor.run {
                            NotificationCenter.default.post(name: .mediaItemsDeleted, object: nil)
                        }
                    }
                }
                continuation.resume()
            }
        }
    }
}

private extension LivePhotosViewModel {
    func fetchLivePhotos() async {
        await MainActor.run {
            isLoading = true
        }
        
        let fetchedItems = await photoFetchService.fetchLivePhotos()
        let size = await mediaCountService.calculateLivePhotosSize()
        
        await MainActor.run {
            items = fetchedItems
            count = fetchedItems.count
            totalSize = ByteSizeFormatter.format(size)
            isLoading = false
        }
    }
}
 
