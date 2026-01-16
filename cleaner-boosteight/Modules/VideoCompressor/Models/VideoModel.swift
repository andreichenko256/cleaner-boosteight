import Foundation
import Photos
import UIKit

struct VideoModel {
    let asset: PHAsset
    let thumbnail: UIImage?
    let size: UInt64
    let duration: TimeInterval
    
    var formattedSize: String {
        return ByteSizeFormatter.format(size)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
