import Foundation
import Combine

final class MainViewModel {
    
    struct DiskInfoDisplayModel {
        let usedSpaceText: String
        let totalSpaceText: String
        let usagePercentage: Double
    }
    
    private let diskInfoService: DiskInfoServiceProtocol
    private let permissionService: PermissionServiceProtocol
    private let mediaCountService: MediaCountServiceProtocol
    
    @Published private(set) var diskInfoDisplayModel: DiskInfoDisplayModel?
    @Published private(set) var error: Error?
    @Published private(set) var permissionGranted: Bool?
    @Published private(set) var medias: [MediaGroupModel] = []
    
    init(
        diskInfoService: DiskInfoServiceProtocol = DiskInfoService(),
        permissionService: PermissionServiceProtocol = PermissionService(),
        mediaCountService: MediaCountServiceProtocol = MediaCountService()
    ) {
        self.diskInfoService = diskInfoService
        self.permissionService = permissionService
        self.mediaCountService = mediaCountService
        loadMediaData()
    }
}

private extension MainViewModel {
    func loadMediaData() {
        let videoCount = mediaCountService.countAllVideos()
        let mediaCount = mediaCountService.countAllMedia()
        
        medias = [
            .init(type: .videoCompressor, mediaCount: videoCount, mediaSize: 0, isLocked: true),
            .init(type: .media, mediaCount: mediaCount, mediaSize: 0, isLocked: true)
        ]
    }
}

extension MainViewModel {
    func refreshData() {
        loadDiskInfo()
        
        let status = permissionService.checkPhotoLibraryStatus()
        if status == .authorized {
            updateMediaCounts()
        }
    }
    
    func loadDiskInfo() {
        do {
            let diskInfo = try diskInfoService.getDiskInfo()
            
            let usedSpaceFormatted = diskInfo.usedSpace.formattedBytesRounded(to: 1)
            let totalSpaceFormatted = "of \(diskInfo.totalSpace.formattedBytesRounded(to: 1))"
            
            diskInfoDisplayModel = DiskInfoDisplayModel(
                usedSpaceText: usedSpaceFormatted,
                totalSpaceText: totalSpaceFormatted,
                usagePercentage: diskInfo.usagePercentage
            )
        } catch let loadError {
            error = loadError
        }
    }
    
    func checkPhotoLibraryPermission() {
        let status = permissionService.checkPhotoLibraryStatus()
        
        switch status {
        case .authorized:
            permissionGranted = true
        case .denied, .restricted:
            permissionGranted = false
        case .notDetermined:
            break
        }
    }
    
    func requestPermissionsAfterDelay() {
        let status = permissionService.checkPhotoLibraryStatus()
        
        guard status == .notDetermined else {
            return
        }
        
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await requestPhotoLibraryPermission()
        }
    }
    
    func requestPhotoLibraryPermission() async {
        let granted = await permissionService.requestPhotoLibraryAccess()
        await MainActor.run {
            permissionGranted = granted
        }
    }
    
    func unlockMedia() {
        updateMediaCounts()
        
        medias = medias.map { media in
            var updatedMedia = media
            updatedMedia.isLocked = false
            return updatedMedia
        }
    }
    
    func updateMediaCounts() {
        let videoCount = mediaCountService.countAllVideos()
        let mediaCount = mediaCountService.countAllMedia()
        
        medias = medias.map { media in
            var updatedMedia = media
            switch media.type {
            case .videoCompressor:
                updatedMedia.mediaCount = videoCount
            case .media:
                updatedMedia.mediaCount = mediaCount
            }
            return updatedMedia
        }
    }
}
