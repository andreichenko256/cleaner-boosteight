import Foundation
import Photos
import UIKit

protocol PhotoFetchServiceProtocol {
    func fetchScreenshots() async -> [PhotoAssetModel]
    func fetchLivePhotos() async -> [PhotoAssetModel]
    func fetchScreenRecordings() async -> [PhotoAssetModel]
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
