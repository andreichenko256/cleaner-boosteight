import Foundation
import Photos
import UIKit

protocol VideoFetchServiceProtocol {
    func fetchAllVideos() async -> [VideoModel]
    func requestThumbnail(for asset: PHAsset, targetSize: CGSize) async -> UIImage?
}

final class VideoFetchService: VideoFetchServiceProtocol {
    private let imageManager: PHImageManager
    
    init(imageManager: PHImageManager = .default()) {
        self.imageManager = imageManager
    }
    
    func fetchAllVideos() async -> [VideoModel] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self else {
                    continuation.resume(returning: [])
                    return
                }
                
                let fetchOptions = PHFetchOptions()
                fetchOptions.includeHiddenAssets = false
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                
                let videosResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                var videos: [VideoModel] = []
                
                videosResult.enumerateObjects { asset, _, _ in
                    let size = self.getAssetSize(asset)
                    let duration = asset.duration
                    
                    let video = VideoModel(
                        asset: asset,
                        thumbnail: nil,
                        size: size,
                        duration: duration
                    )
                    videos.append(video)
                }
                
                continuation.resume(returning: videos)
            }
        }
    }
    
    func requestThumbnail(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    private func getAssetSize(_ asset: PHAsset) -> UInt64 {
        let resources = PHAssetResource.assetResources(for: asset)
        var totalSize: UInt64 = 0
        
        for resource in resources {
            if let size = resource.value(forKey: "fileSize") as? UInt64 {
                totalSize += size
            }
        }
        
        return totalSize
    }
}
