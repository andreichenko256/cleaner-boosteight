import Foundation
import Combine
import UIKit

final class MainViewModel {
    
    struct DiskInfoDisplayModel {
        let usedSpaceText: String
        let totalSpaceText: String
        let usagePercentage: Double
    }
    
    private let diskInfoService: DiskInfoServiceProtocol
    private let permissionService: PermissionServiceProtocol
    private let mediaCountService: MediaCountServiceProtocol
    private let mediaCacheService: MediaCacheServiceProtocol
    private let hapticService: HapticServiceProtocol
    
    @Published private(set) var diskInfoDisplayModel: DiskInfoDisplayModel?
    @Published private(set) var error: Error?
    @Published private(set) var permissionGranted: Bool?
    @Published private(set) var medias: [MediaGroupModel] = []
    @Published private(set) var alertModel: AlertModel?
    
    var onMediaGroupTapped: ((MediaType) -> Void)?
    
    init(
        diskInfoService: DiskInfoServiceProtocol = DiskInfoService(),
        permissionService: PermissionServiceProtocol = PermissionService(),
        mediaCountService: MediaCountServiceProtocol = MediaCountService(),
        mediaCacheService: MediaCacheServiceProtocol = MediaCacheService(),
        hapticService: HapticServiceProtocol = HapticService()
    ) {
        self.diskInfoService = diskInfoService
        self.permissionService = permissionService
        self.mediaCountService = mediaCountService
        self.mediaCacheService = mediaCacheService
        self.hapticService = hapticService
        loadMediaData()
    }
    
    private func convertBytesToGB(_ bytes: UInt64) -> Float {
        return Float(bytes) / 1_073_741_824.0
    }
}

private extension MainViewModel {
    func loadMediaData() {
        Task {
            await loadMediaDataAsync()
        }
    }
    
    func loadMediaDataAsync() async {
        let permissionStatus = permissionService.checkPhotoLibraryStatus()
        let isAuthorized = permissionStatus == .authorized
        
        async let videoCountAsync = mediaCountService.countAllVideos()
        async let mediaCountAsync = mediaCountService.countAllMedia()
        
        let videoCount = await videoCountAsync
        let mediaCount = await mediaCountAsync
        
        let cachedVideoInfo = mediaCacheService.getCachedMediaInfo(for: .videos)
        let cachedMediaInfo = mediaCacheService.getCachedMediaInfo(for: .allMedia)
        
        let videoSize: Float
        let mediaSize: Float
        let needsVideoUpdate = cachedVideoInfo == nil || cachedVideoInfo?.count != videoCount
        let needsMediaUpdate = cachedMediaInfo == nil || cachedMediaInfo?.count != mediaCount
        
        if let cachedVideo = cachedVideoInfo, cachedVideo.count == videoCount {
            videoSize = convertBytesToGB(cachedVideo.size)
        } else {
            videoSize = 0
        }
        
        if let cachedMedia = cachedMediaInfo, cachedMedia.count == mediaCount {
            mediaSize = convertBytesToGB(cachedMedia.size)
        } else {
            mediaSize = 0
        }
        
        await MainActor.run {
            medias = [
                .init(type: .videoCompressor, mediaCount: videoCount, mediaSize: videoSize, isLocked: !isAuthorized, isLoading: needsVideoUpdate),
                .init(type: .media, mediaCount: mediaCount, mediaSize: mediaSize, isLocked: !isAuthorized, isLoading: needsMediaUpdate)
            ]
        }
        
        if needsVideoUpdate || needsMediaUpdate {
            await loadMediaSizes(
                updateVideos: needsVideoUpdate,
                updateMedia: needsMediaUpdate,
                videoCount: videoCount,
                mediaCount: mediaCount
            )
        }
    }
    
    func loadMediaSizes(
        updateVideos: Bool,
        updateMedia: Bool,
        videoCount: Int,
        mediaCount: Int
    ) async {
        var videoSize: UInt64 = 0
        var mediaSize: UInt64 = 0
        
        if updateVideos {
            videoSize = await mediaCountService.calculateAllVideosSize()
            mediaCacheService.saveMediaInfo(
                CachedMediaInfo(count: videoCount, size: videoSize, timestamp: Date()),
                for: .videos
            )
        }
        
        if updateMedia {
            mediaSize = await mediaCountService.calculateAllMediaSize()
            mediaCacheService.saveMediaInfo(
                CachedMediaInfo(count: mediaCount, size: mediaSize, timestamp: Date()),
                for: .allMedia
            )
        }
        
        await MainActor.run {
            medias = medias.map { media in
                var updatedMedia = media
                switch media.type {
                case .videoCompressor:
                    if updateVideos {
                        updatedMedia.mediaSize = convertBytesToGB(videoSize)
                        updatedMedia.isLoading = false
                    }
                case .media:
                    if updateMedia {
                        updatedMedia.mediaSize = convertBytesToGB(mediaSize)
                        updatedMedia.isLoading = false
                    }
                }
                return updatedMedia
            }
        }
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
    
    func refreshDataWithCacheClear() {
        loadDiskInfo()
        
        let status = permissionService.checkPhotoLibraryStatus()
        if status == .authorized {
            mediaCacheService.clearCache(for: .videos)
            mediaCacheService.clearCache(for: .allMedia)
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
            unlockMedia()
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
        Task {
            await updateMediaCountsAsync()
        }
    }
    
    private func updateMediaCountsAsync() async {
        async let videoCountAsync = mediaCountService.countAllVideos()
        async let mediaCountAsync = mediaCountService.countAllMedia()
        
        let videoCount = await videoCountAsync
        let mediaCount = await mediaCountAsync
        
        let cachedVideoInfo = mediaCacheService.getCachedMediaInfo(for: .videos)
        let cachedMediaInfo = mediaCacheService.getCachedMediaInfo(for: .allMedia)
        
        let needsVideoUpdate = cachedVideoInfo == nil || cachedVideoInfo?.count != videoCount
        let needsMediaUpdate = cachedMediaInfo == nil || cachedMediaInfo?.count != mediaCount
        
        await MainActor.run {
            medias = medias.map { media in
                var updatedMedia = media
                switch media.type {
                case .videoCompressor:
                    updatedMedia.mediaCount = videoCount
                    updatedMedia.isLoading = needsVideoUpdate
                    if let cached = cachedVideoInfo, cached.count == videoCount {
                        updatedMedia.mediaSize = convertBytesToGB(cached.size)
                    }
                case .media:
                    updatedMedia.mediaCount = mediaCount
                    updatedMedia.isLoading = needsMediaUpdate
                    if let cached = cachedMediaInfo, cached.count == mediaCount {
                        updatedMedia.mediaSize = convertBytesToGB(cached.size)
                    }
                }
                return updatedMedia
            }
        }
        
        if needsVideoUpdate || needsMediaUpdate {
            await loadMediaSizes(
                updateVideos: needsVideoUpdate,
                updateMedia: needsMediaUpdate,
                videoCount: videoCount,
                mediaCount: mediaCount
            )
        }
    }
    
    func handleMediaCellTap(type: MediaType) {
        let status = permissionService.checkPhotoLibraryStatus()
        
        guard status == .authorized else {
            showPermissionDeniedAlert()
            return
        }
        
        onMediaGroupTapped?(type)
    }
    
    private func showPermissionDeniedAlert() {
        alertModel = AlertModel(
            title: "Access Denied",
            message: "Photo library access is required to view your media. Please enable it in Settings.",
            primaryAction: .init(title: "Settings", style: .openSettings, handler: nil),
            secondaryAction: .init(title: "Cancel", style: .cancel, handler: nil)
        )
    }
}
