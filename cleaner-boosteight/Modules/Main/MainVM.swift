import Foundation
import Combine

final class MainViewModel {
    
    struct DiskInfoDisplayModel {
        let usedSpaceText: String
        let totalSpaceText: String
        let usagePercentage: Double
    }
    
    private let diskInfoService: DiskInfoServiceProtocol
    
    @Published private(set) var diskInfoDisplayModel: DiskInfoDisplayModel?
    @Published private(set) var error: Error?
    
    init(diskInfoService: DiskInfoServiceProtocol = DiskInfoService()) {
        self.diskInfoService = diskInfoService
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
}
