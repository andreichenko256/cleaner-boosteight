import Foundation

struct DiskInfo {
    let totalSpace: Byte
    let availableSpace: Byte
    let usedSpace: Byte
    
    var usagePercentage: Double {
        guard totalSpace > 0 else { return 0 }
        return Double(usedSpace) / Double(totalSpace)
    }
}
