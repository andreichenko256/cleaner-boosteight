import Foundation
import Photos

protocol PermissionServiceProtocol {
    func requestPhotoLibraryAccess() async -> Bool
    func checkPhotoLibraryStatus() -> PermissionStatus
}

enum PermissionStatus {
    case notDetermined
    case authorized
    case denied
    case restricted
}

final class PermissionService: PermissionServiceProtocol {
    
    func requestPhotoLibraryAccess() async -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            return true
        case .notDetermined:
            let newStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return newStatus == .authorized || newStatus == .limited
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    func checkPhotoLibraryStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            return .notDetermined
        case .authorized, .limited:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
}
