import Foundation
import Combine

final class MainViewModel {
    
    struct DiskInfoDisplayModel {
        let usedSpaceText: String
        let totalSpaceText: String
        let usagePercentage: Double
    }
    
    private let diskInfoService: DiskInfoServiceProtocol
    private let permissionService: PermissionServiceProtocol
    
    @Published private(set) var diskInfoDisplayModel: DiskInfoDisplayModel?
    @Published private(set) var error: Error?
    @Published private(set) var permissionGranted: Bool?
    
    init(
        diskInfoService: DiskInfoServiceProtocol = DiskInfoService(),
        permissionService: PermissionServiceProtocol = PermissionService()
    ) {
        self.diskInfoService = diskInfoService
        self.permissionService = permissionService
    }
    
    func loadDiskInfo() {
        do {
            let diskInfo = try diskInfoService.getDiskInfo()
            
            let usedSpaceFormatted = diskInfo.usedSpace.formattedBytesRounded(to: 1)
            let totalSpaceFormatted = "of \(diskInfo.totalSpace.formattedBytesRounded(to: 1))"
            
            diskInfoDisplayModel = DiskInfoDisplayModel(
                usedSpaceText: usedSpaceFormatted,
                totalSpaceText: totalSpaceFormatted,
                usagePercentage: diskInfo.usagePercentage
            )
        } catch let loadError {
            error = loadError
        }
    }
    
    func requestPhotoLibraryPermission() async {
        let granted = await permissionService.requestPhotoLibraryAccess()
        await MainActor.run {
            permissionGranted = granted
        }
    }
}
