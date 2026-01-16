import UIKit

enum MediaItemType {
    case duplicatePhotos
    case similarPhotos
    case screenshots
    case livePhotos
    case screenRecordings
    case similarVideos
}

struct MediaModel {
    let type: MediaItemType
    let title: String
    var count: String
    let image: UIImage?
    var isLoading: Bool
}
