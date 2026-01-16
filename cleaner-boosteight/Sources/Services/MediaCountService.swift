import Foundation
import Photos

protocol MediaCountServiceProtocol {
    func countAllPhotos() -> Int
    func countAllVideos() -> Int
    func countAllMedia() -> Int
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
}
