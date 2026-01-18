import Foundation
import Combine
import UIKit

final class MediaViewModel {
    @Published private(set) var mediaItems: [MediaModel] = []
    
    var onMediaItemTapped: ((MediaItemType) -> Void)?
    
    private let mediaCountService: MediaCountServiceProtocol
    
    init(mediaCountService: MediaCountServiceProtocol = MediaCountService()) {
        self.mediaCountService = mediaCountService
        Task {
            await loadMediaData()
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMediaDeleted),
            name: .mediaItemsDeleted,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension MediaViewModel {
    func loadMediaData() async {
        await MainActor.run {
            mediaItems = [
                MediaModel(type: .duplicatePhotos, title: "Duplicate Photos", count: "0", image: .duplicatePhotosMedia, isLoading: true),
                MediaModel(type: .similarPhotos, title: "Similar Photos", count: "0", image: .similarPhotosVideosMedia, isLoading: true),
                MediaModel(type: .screenshots, title: "Screenshots", count: "0", image: .screenshotsMedia, isLoading: true),
                MediaModel(type: .livePhotos, title: "Live Photos", count: "0", image: .livePhotosMedia, isLoading: true),
                MediaModel(type: .screenRecordings, title: "Screen Recordings", count: "0", image: .screenRecordingsMedia, isLoading: true),
                MediaModel(type: .similarVideos, title: "Similar Videos", count: "0", image: .similarPhotosVideosMedia, isLoading: true)
            ]
        }
        
        async let duplicateCount = mediaCountService.countDuplicatePhotos()
        async let similarPhotosCount = mediaCountService.countSimilarPhotos()
        async let screenshotsCount = mediaCountService.countScreenshots()
        async let livePhotosCount = mediaCountService.countLivePhotos()
        async let screenRecordingsCount = mediaCountService.countScreenRecordings()
        async let similarVideosCount = mediaCountService.countSimilarVideos()
        
        let counts = await (
            duplicate: duplicateCount,
            similarPhotos: similarPhotosCount,
            screenshots: screenshotsCount,
            livePhotos: livePhotosCount,
            screenRecordings: screenRecordingsCount,
            similarVideos: similarVideosCount
        )
        
        await MainActor.run {
            mediaItems = [
                MediaModel(
                    type: .duplicatePhotos,
                    title: "Duplicate Photos",
                    count: "\(counts.duplicate)",
                    image: .duplicatePhotosMedia,
                    isLoading: false
                ),
                MediaModel(
                    type: .similarPhotos,
                    title: "Similar Photos",
                    count: "\(counts.similarPhotos)",
                    image: .similarPhotosVideosMedia,
                    isLoading: false
                ),
                MediaModel(
                    type: .screenshots,
                    title: "Screenshots",
                    count: "\(counts.screenshots)",
                    image: .screenshotsMedia,
                    isLoading: false
                ),
                MediaModel(
                    type: .livePhotos,
                    title: "Live Photos",
                    count: "\(counts.livePhotos)",
                    image: .livePhotosMedia,
                    isLoading: false
                ),
                MediaModel(
                    type: .screenRecordings,
                    title: "Screen Recordings",
                    count: "\(counts.screenRecordings)",
                    image: .screenRecordingsMedia,
                    isLoading: false
                ),
                MediaModel(
                    type: .similarVideos,
                    title: "Similar Videos",
                    count: "\(counts.similarVideos)",
                    image: .similarPhotosVideosMedia,
                    isLoading: false
                )
            ]
        }
    }
    
    @objc func handleMediaDeleted() {
        Task {
            await loadMediaData()
        }
    }
}

extension MediaViewModel {
    func handleMediaItemTap(at index: Int) {
        guard index < mediaItems.count else { return }
        let item = mediaItems[index]
        onMediaItemTapped?(item.type)
    }
    
    func refreshMediaData() {
        Task {
            await loadMediaData()
        }
    }
}
