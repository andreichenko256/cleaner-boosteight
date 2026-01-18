import Combine
import Photos
import Foundation

final class DuplicatePhotosViewModel {
    private let photoFetchService: PhotoFetchServiceProtocol
    private let mediaCountService: MediaCountServiceProtocol
    
    @Published private(set) var duplicateGroups: [[PHAsset]] = []
    @Published private(set) var count: Int = 0
    @Published private(set) var totalSize: String = "0 MB"
    @Published private(set) var isLoading: Bool = false
    
    init(
        photoFetchService: PhotoFetchServiceProtocol = PhotoFetchService(),
        mediaCountService: MediaCountServiceProtocol = MediaCountService()
    ) {
        self.photoFetchService = photoFetchService
        self.mediaCountService = mediaCountService
    }
    
    func loadData() {
        guard duplicateGroups.isEmpty && !isLoading else { return }
        
        Task {
            await fetchDuplicateGroups()
        }
    }
    
    func refreshData() {
        Task {
            await fetchDuplicateGroups()
        }
    }
}

private extension DuplicatePhotosViewModel {
    func fetchDuplicateGroups() async {
        await MainActor.run {
            isLoading = true
        }
        
        let groups = await photoFetchService.fetchDuplicatePhotoGroups()
        let allAssets = groups.flatMap { $0 }
        let size = photoFetchService.calculateSize(for: allAssets)
        
        await MainActor.run {
            duplicateGroups = groups
            count = groups.reduce(0) { $0 + ($1.count - 1) }
            totalSize = ByteSizeFormatter.format(size)
            isLoading = false
        }
    }
}
