import Foundation
import Photos
import UIKit

protocol PhotoFetchServiceProtocol {
    func fetchScreenshots() async -> [PhotoAssetModel]
    func fetchLivePhotos() async -> [PhotoAssetModel]
    func fetchScreenRecordings() async -> [PhotoAssetModel]
    func fetchDuplicatePhotoGroups() async -> [[PHAsset]]
    func fetchSimilarPhotoGroups() async -> [[PHAsset]]
    func fetchSimilarVideoGroups() async -> [[PHAsset]]
    func requestThumbnail(for asset: PHAsset, targetSize: CGSize) async -> UIImage?
    func calculateSize(for assets: [PHAsset]) -> UInt64
}

final class PhotoFetchService: PhotoFetchServiceProtocol {
    private let imageManager: PHImageManager
    
    init(imageManager: PHImageManager = .default()) {
        self.imageManager = imageManager
    }
    
    func fetchScreenshots() async -> [PhotoAssetModel] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.predicate = NSPredicate(
                    format: "(mediaSubtype & %d) != 0",
                    PHAssetMediaSubtype.photoScreenshot.rawValue
                )
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                var photos: [PhotoAssetModel] = []
                
                result.enumerateObjects { asset, _, _ in
                    photos.append(PhotoAssetModel(asset: asset))
                }
                
                continuation.resume(returning: photos)
            }
        }
    }
    
    func fetchLivePhotos() async -> [PhotoAssetModel] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.predicate = NSPredicate(
                    format: "(mediaSubtype & %d) != 0",
                    PHAssetMediaSubtype.photoLive.rawValue
                )
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                var photos: [PhotoAssetModel] = []
                
                result.enumerateObjects { asset, _, _ in
                    photos.append(PhotoAssetModel(asset: asset))
                }
                
                continuation.resume(returning: photos)
            }
        }
    }
    
    func fetchScreenRecordings() async -> [PhotoAssetModel] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                var screenRecordings: [PhotoAssetModel] = []
                
                videosResult.enumerateObjects { asset, _, _ in
                    if self.isScreenRecording(asset) {
                        screenRecordings.append(PhotoAssetModel(asset: asset))
                    }
                }
                
                continuation.resume(returning: screenRecordings)
            }
        }
    }
    
    func fetchDuplicatePhotoGroups() async -> [[PHAsset]] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.includeAllBurstAssets = false
                
                let photosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                var assetsBySize: [UInt64: [PHAsset]] = [:]
                
                photosResult.enumerateObjects { asset, _, _ in
                    let resources = PHAssetResource.assetResources(for: asset)
                    if let resource = resources.first,
                       let fileSize = resource.value(forKey: "fileSize") as? UInt64 {
                        assetsBySize[fileSize, default: []].append(asset)
                    }
                }
                
                let duplicateGroups = assetsBySize.values.filter { $0.count > 1 }
                
                continuation.resume(returning: Array(duplicateGroups))
            }
        }
    }
    
    func fetchSimilarPhotoGroups() async -> [[PHAsset]] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.includeAllBurstAssets = false
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                let photosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                var assetsWithMetadata: [(asset: PHAsset, date: Date?, width: Int, height: Int)] = []
                photosResult.enumerateObjects { asset, _, _ in
                    assetsWithMetadata.append((
                        asset: asset,
                        date: asset.creationDate,
                        width: asset.pixelWidth,
                        height: asset.pixelHeight
                    ))
                }
                
                var similarGroups: [[PHAsset]] = []
                var currentGroup: [PHAsset] = []
                var previousData: (asset: PHAsset, date: Date?, width: Int, height: Int)?
                
                for data in assetsWithMetadata {
                    if let previous = previousData {
                        let timeDifference = abs(data.date?.timeIntervalSince(previous.date ?? Date()) ?? 0)
                        
                        if timeDifference < 10 &&
                           abs(previous.width - data.width) < 100 &&
                           abs(previous.height - data.height) < 100 {
                            if currentGroup.isEmpty {
                                currentGroup.append(previous.asset)
                            }
                            currentGroup.append(data.asset)
                        } else {
                            if currentGroup.count > 1 {
                                similarGroups.append(currentGroup)
                            }
                            currentGroup = []
                        }
                    }
                    
                    previousData = data
                }
                
                if currentGroup.count > 1 {
                    similarGroups.append(currentGroup)
                }
                
                continuation.resume(returning: similarGroups)
            }
        }
    }
    
    func fetchSimilarVideoGroups() async -> [[PHAsset]] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                
                var assetsWithMetadata: [(asset: PHAsset, date: Date?, duration: TimeInterval)] = []
                videosResult.enumerateObjects { asset, _, _ in
                    assetsWithMetadata.append((
                        asset: asset,
                        date: asset.creationDate,
                        duration: asset.duration
                    ))
                }
                
                var similarGroups: [[PHAsset]] = []
                var currentGroup: [PHAsset] = []
                var previousData: (asset: PHAsset, date: Date?, duration: TimeInterval)?
                
                for data in assetsWithMetadata {
                    if let previous = previousData {
                        let timeDifference = abs(data.date?.timeIntervalSince(previous.date ?? Date()) ?? 0)
                        let durationDifference = abs(previous.duration - data.duration)
                        
                        if timeDifference < 30 && durationDifference < 5 {
                            if currentGroup.isEmpty {
                                currentGroup.append(previous.asset)
                            }
                            currentGroup.append(data.asset)
                        } else {
                            if currentGroup.count > 1 {
                                similarGroups.append(currentGroup)
                            }
                            currentGroup = []
                        }
                    }
                    
                    previousData = data
                }
                
                if currentGroup.count > 1 {
                    similarGroups.append(currentGroup)
                }
                
                continuation.resume(returning: similarGroups)
            }
        }
    }
    
    func requestThumbnail(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            options.resizeMode = .fast
            
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, info in
                if let isDegraded = info?[PHImageResultIsDegradedKey] as? Bool, isDegraded {
                    return
                }
                continuation.resume(returning: image)
            }
        }
    }
    
    func calculateSize(for assets: [PHAsset]) -> UInt64 {
        var totalSize: UInt64 = 0
        
        for asset in assets {
            let resources = PHAssetResource.assetResources(for: asset)
            for resource in resources {
                if let size = resource.value(forKey: "fileSize") as? UInt64 {
                    totalSize += size
                }
            }
        }
        
        return totalSize
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
