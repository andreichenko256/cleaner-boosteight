import Foundation
import Photos
import UIKit

protocol MediaCountServiceProtocol {
    func countAllPhotos() async -> Int
    func countAllVideos() async -> Int
    func countAllMedia() async -> Int
    func calculateAllVideosSize() async -> UInt64
    func calculateAllMediaSize() async -> UInt64
    
    func countScreenshots() async -> Int
    func countLivePhotos() async -> Int
    func countScreenRecordings() async -> Int
    func countDuplicatePhotos() async -> Int
    func countSimilarPhotos() async -> Int
    func countSimilarVideos() async -> Int
    
    func calculateScreenshotsSize() async -> UInt64
    func calculateLivePhotosSize() async -> UInt64
    func calculateScreenRecordingsSize() async -> UInt64
}

final class MediaCountService: MediaCountServiceProtocol {
    private let imageManager: PHImageManager
    
    init(imageManager: PHImageManager = .default()) {
        self.imageManager = imageManager
    }
    
    func countAllPhotos() async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.includeAllBurstAssets = false
                
                let photosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                continuation.resume(returning: photosResult.count)
            }
        }
    }
    
    func countAllVideos() async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                
                let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                continuation.resume(returning: videosResult.count)
            }
        }
    }
    
    func countAllMedia() async -> Int {
        async let photosCount = countAllPhotos()
        async let videosCount = countAllVideos()
        return await photosCount + videosCount
    }
    
    func calculateAllVideosSize() async -> UInt64 {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                
                let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                let size = self.calculateSizeForAssets(videosResult)
                continuation.resume(returning: size)
            }
        }
    }
    
    func calculateAllMediaSize() async -> UInt64 {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.includeAllBurstAssets = false
                
                let allMediaResult = PHAsset.fetchAssets(with: fetchOptions)
                let size = self.calculateSizeForAssets(allMediaResult)
                continuation.resume(returning: size)
            }
        }
    }
    
    private func calculateSizeForAssets(_ fetchResult: PHFetchResult<PHAsset>) -> UInt64 {
        var totalSize: UInt64 = 0
        
        fetchResult.enumerateObjects { asset, _, _ in
            let resources = PHAssetResource.assetResources(for: asset)
            for resource in resources {
                if let unsignedInt64 = resource.value(forKey: "fileSize") as? UInt64 {
                    totalSize += unsignedInt64
                }
            }
        }
        
        return totalSize
    }
}

extension MediaCountService {
    func countScreenshots() async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.predicate = NSPredicate(
                    format: "(mediaSubtype & %d) != 0",
                    PHAssetMediaSubtype.photoScreenshot.rawValue
                )
                
                let screenshotsResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                continuation.resume(returning: screenshotsResult.count)
            }
        }
    }
    
    func countLivePhotos() async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.predicate = NSPredicate(
                    format: "(mediaSubtype & %d) != 0",
                    PHAssetMediaSubtype.photoLive.rawValue
                )
                
                let livePhotosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                continuation.resume(returning: livePhotosResult.count)
            }
        }
    }
    
    func countScreenRecordings() async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                
                let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                var screenRecordingsCount = 0
                
                videosResult.enumerateObjects { asset, _, _ in
                    if self.isScreenRecording(asset) {
                        screenRecordingsCount += 1
                    }
                }
                
                continuation.resume(returning: screenRecordingsCount)
            }
        }
    }
    
    func countDuplicatePhotos() async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.includeAllBurstAssets = false
                
                let photosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                var duplicatesCount = 0
                var assetsBySize: [UInt64: [PHAsset]] = [:]
                
                photosResult.enumerateObjects { asset, _, _ in
                    let resources = PHAssetResource.assetResources(for: asset)
                    if let resource = resources.first,
                       let fileSize = resource.value(forKey: "fileSize") as? UInt64 {
                        assetsBySize[fileSize, default: []].append(asset)
                    }
                }
                
                for (_, assets) in assetsBySize where assets.count > 1 {
                    duplicatesCount += assets.count - 1
                }
                
                continuation.resume(returning: duplicatesCount)
            }
        }
    }
    
    func countSimilarPhotos() async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.includeAllBurstAssets = false
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                let photosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                var similarCount = 0
                var previousAsset: PHAsset?
                
                photosResult.enumerateObjects { asset, _, _ in
                    if let previous = previousAsset,
                       let prevDate = previous.creationDate,
                       let currDate = asset.creationDate {
                        let timeDifference = abs(currDate.timeIntervalSince(prevDate))
                        
                        if timeDifference < 10 && 
                           abs(previous.pixelWidth - asset.pixelWidth) < 100 &&
                           abs(previous.pixelHeight - asset.pixelHeight) < 100 {
                            similarCount += 1
                        }
                    }
                    previousAsset = asset
                }
                
                continuation.resume(returning: similarCount)
            }
        }
    }
    
    func countSimilarVideos() async -> Int {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                
                var similarCount = 0
                var previousAsset: PHAsset?
                
                videosResult.enumerateObjects { asset, _, _ in
                    if let previous = previousAsset,
                       let prevDate = previous.creationDate,
                       let currDate = asset.creationDate {
                        let timeDifference = abs(currDate.timeIntervalSince(prevDate))
                        let durationDifference = abs(previous.duration - asset.duration)
                        
                        if timeDifference < 30 && durationDifference < 5 {
                            similarCount += 1
                        }
                    }
                    previousAsset = asset
                }
                
                continuation.resume(returning: similarCount)
            }
        }
    }
    
    func calculateScreenshotsSize() async -> UInt64 {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.predicate = NSPredicate(
                    format: "(mediaSubtype & %d) != 0",
                    PHAssetMediaSubtype.photoScreenshot.rawValue
                )
                
                let screenshotsResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                let size = self.calculateSizeForAssets(screenshotsResult)
                continuation.resume(returning: size)
            }
        }
    }
    
    func calculateLivePhotosSize() async -> UInt64 {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.predicate = NSPredicate(
                    format: "(mediaSubtype & %d) != 0",
                    PHAssetMediaSubtype.photoLive.rawValue
                )
                
                let livePhotosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                let size = self.calculateSizeForAssets(livePhotosResult)
                continuation.resume(returning: size)
            }
        }
    }
    
    func calculateScreenRecordingsSize() async -> UInt64 {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                
                let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                var totalSize: UInt64 = 0
                
                videosResult.enumerateObjects { asset, _, _ in
                    if self.isScreenRecording(asset) {
                        let resources = PHAssetResource.assetResources(for: asset)
                        for resource in resources {
                            if let size = resource.value(forKey: "fileSize") as? UInt64 {
                                totalSize += size
                            }
                        }
                    }
                }
                
                continuation.resume(returning: totalSize)
            }
        }
    }
    
    private func isScreenRecording(_ asset: PHAsset) -> Bool {
        guard asset.mediaType == .video else { return false }
        
        let resources = PHAssetResource.assetResources(for: asset)
        
        for resource in resources {
            if resource.type == .video {
                let filename = resource.originalFilename.lowercased()
                if filename.contains("rpreplay") || 
                   filename.contains("screen recording") ||
                   filename.contains("screenrecording") {
                    return true
                }
            }
        }
        
        let screenWidth = Int(UIScreen.main.bounds.width * UIScreen.main.scale)
        let screenHeight = Int(UIScreen.main.bounds.height * UIScreen.main.scale)
        
        let videoWidth = asset.pixelWidth
        let videoHeight = asset.pixelHeight
        
        if (videoWidth == screenWidth && videoHeight == screenHeight) ||
           (videoWidth == screenHeight && videoHeight == screenWidth) {
            return true
        }
        
        return false
    }
}
