import Foundation
import Photos

struct PhotoAssetModel: Identifiable {
    let id: String
    let asset: PHAsset
    var isSelected: Bool
    
    init(asset: PHAsset, isSelected: Bool = false) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.isSelected = isSelected
    }
}
