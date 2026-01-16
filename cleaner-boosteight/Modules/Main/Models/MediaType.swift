import UIKit

enum MediaType {
    case videoCompressor
    case media
    
    var title: String {
        switch self {
        case .videoCompressor:
            return "Video Compressor"
        case .media:
            return "Media"
        }
    }
    
    var image: UIImage {
        switch self {
        case .videoCompressor:
            return .videoGroupIcon
        case .media:
            return .mediaGroupIcon
        }
    }
    
    var previewImage: UIImage {
        switch self {
        case .videoCompressor:
            return .videoCompressorPreview
        case .media:
            return .mediaPreview
        }
    }
}
