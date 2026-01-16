import Foundation
import Combine
import UIKit

final class MediaViewModel {
    
    private let mediaCountService: MediaCountServiceProtocol
    
    @Published private(set) var mediaItems: [MediaModel] = []
    
    init(mediaCountService: MediaCountServiceProtocol = MediaCountService()) {
        self.mediaCountService = mediaCountService
        Task {
            await loadMediaData()
        }
    }
}

private extension MediaViewModel {
    func loadMediaData() async {
        await MainActor.run {
            mediaItems = [
                MediaModel(title: "Duplicate Photos", count: "0", image: .duplicatePhotosMedia, isLoading: true),
                MediaModel(title: "Similar Photos", count: "0", image: .similarPhotosVideosMedia, isLoading: true),
                MediaModel(title: "Screenshots", count: "0", image: .screenshotsMedia, isLoading: true),
                MediaModel(title: "Live Photos", count: "0", image: .livePhotosMedia, isLoading: true),
                MediaModel(title: "Screen Recordings", count: "0", image: .screenRecordingsMedia, isLoading: true),
                MediaModel(title: "Similar Videos", count: "0", image: .similarPhotosVideosMedia, isLoading: true)
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
                    title: "Duplicate Photos",
                    count: "\(counts.duplicate)",
                    image: .duplicatePhotosMedia,
                    isLoading: false
                ),
                MediaModel(
                    title: "Similar Photos",
                    count: "\(counts.similarPhotos)",
                    image: .similarPhotosVideosMedia,
                    isLoading: false
                ),
                MediaModel(
                    title: "Screenshots",
                    count: "\(counts.screenshots)",
                    image: .screenshotsMedia,
                    isLoading: false
                ),
                MediaModel(
                    title: "Live Photos",
                    count: "\(counts.livePhotos)",
                    image: .livePhotosMedia,
                    isLoading: false
                ),
                MediaModel(
                    title: "Screen Recordings",
                    count: "\(counts.screenRecordings)",
                    image: .screenRecordingsMedia,
                    isLoading: false
                ),
                MediaModel(
                    title: "Similar Videos",
                    count: "\(counts.similarVideos)",
                    image: .similarPhotosVideosMedia,
                    isLoading: false
                )
            ]
        }
    }
}

extension MediaViewModel {
    func refreshMediaData() {
        Task {
            await loadMediaData()
        }
    }
}
