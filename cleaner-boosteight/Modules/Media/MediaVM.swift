import Foundation
import Combine
import UIKit

final class MediaViewModel {
    
    @Published private(set) var mediaItems: [MediaModel] = []
    
    init() {
        loadMediaData()
    }
}

private extension MediaViewModel {
    func loadMediaData() {
        mediaItems = [
            MediaModel(
                title: "Duplicate Photos",
                count: "0",
                image: .duplicatePhotosMedia
            ),
            MediaModel(
                title: "Similar Photos",
                count: "0",
                image: .similarPhotosVideosMedia
            ),
            MediaModel(
                title: "Screenshots",
                count: "0",
                image: .screenshotsMedia
            ),
            MediaModel(
                title: "Live Photos",
                count: "0",
                image: .livePhotosMedia
            ),
            MediaModel(
                title: "Screen Recordings",
                count: "0",
                image: .screenRecordingsMedia
            ),
            MediaModel(
                title: "Similar Videos",
                count: "0",
                image: .similarPhotosVideosMedia
            )
        ]
    }
}
