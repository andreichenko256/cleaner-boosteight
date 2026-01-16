import Foundation
import Photos

protocol MediaCountServiceProtocol {
    func countAllPhotos() -> Int
    func countAllVideos() -> Int
    func countAllMedia() -> Int
    func calculateAllVideosSize() async -> UInt64
    func calculateAllMediaSize() async -> UInt64
}

final class MediaCountService: MediaCountServiceProtocol {
    private let imageManager: PHImageManager
    
    init(imageManager: PHImageManager = .default()) {
        self.imageManager = imageManager
    }
    
    func countAllPhotos() -> Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        fetchOptions.includeAllBurstAssets = false
        
        let photosResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        return photosResult.count
    }
    
    func countAllVideos() -> Int {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeHiddenAssets = false
        
        let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        return videosResult.count
    }
    
    func countAllMedia() -> Int {
        return countAllPhotos() + countAllVideos()
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
