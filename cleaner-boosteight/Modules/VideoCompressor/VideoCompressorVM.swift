import Foundation
import Photos
import UIKit

protocol VideoCompressorVMProtocol: AnyObject {
    var videos: [VideoModel] { get }
    var videosCount: Int { get }
    var totalSize: UInt64 { get }
    var formattedTotalSize: String { get }
    var onVideosUpdated: VoidBlock? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func loadVideos()
    func getThumbnail(for index: Int, targetSize: CGSize, completion: @escaping (UIImage?) -> Void)
}

final class VideoCompressorVM: VideoCompressorVMProtocol {
    private let videoFetchService: VideoFetchServiceProtocol
    private(set) var videos: [VideoModel] = []
    
    var onVideosUpdated: VoidBlock?
    var onError: ((String) -> Void)?
    
    var videosCount: Int {
        return videos.count
    }
    
    var totalSize: UInt64 {
        return videos.reduce(0) { $0 + $1.size }
    }
    
    var formattedTotalSize: String {
        return ByteSizeFormatter.format(totalSize)
    }
    
    init(videoFetchService: VideoFetchServiceProtocol = VideoFetchService()) {
        self.videoFetchService = videoFetchService
    }
    
    func loadVideos() {
        Task { @MainActor in
            await checkPermissionAndLoadVideos()
        }
    }
    
    func getThumbnail(for index: Int, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        guard index < videos.count else {
            completion(nil)
            return
        }
        
        let asset = videos[index].asset
        
        Task {
            let thumbnail = await videoFetchService.requestThumbnail(for: asset, targetSize: targetSize)
            await MainActor.run {
                completion(thumbnail)
            }
        }
    }
    
    @MainActor
    private func checkPermissionAndLoadVideos() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            await fetchVideos()
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            if newStatus == .authorized || newStatus == .limited {
                await fetchVideos()
            } else {
                onError?("Access to photos is required to load videos")
            }
        case .denied, .restricted:
            onError?("Access to photos is denied. Please enable it in Settings")
        @unknown default:
            onError?("Unknown authorization status")
        }
    }
    
    @MainActor
    private func fetchVideos() async {
        videos = await videoFetchService.fetchAllVideos()
        onVideosUpdated?()
    }
}
