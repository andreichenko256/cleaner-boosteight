import Foundation

protocol DiskInfoServiceProtocol {
    func getDiskInfo() throws -> DiskInfo
}

enum DiskInfoError: Error {
    case unableToGetDiskInfo
    case invalidPath
}

final class DiskInfoService: DiskInfoServiceProtocol {
    
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func getDiskInfo() throws -> DiskInfo {
        let totalCapacity = getTotalDiskCapacity()
        let availableSpace = getAvailableDiskSpace()
        let usedSpace = totalCapacity > availableSpace ? totalCapacity - availableSpace : 0
        
        return DiskInfo(
            totalSpace: totalCapacity,
            availableSpace: availableSpace,
            usedSpace: usedSpace
        )
    }
    
    private func getTotalDiskCapacity() -> UInt64 {
        if let attributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let size = attributes[.systemSize] as? NSNumber {
            return size.uint64Value
        }
        return ProcessInfo.processInfo.physicalMemory
    }
    
    private func getAvailableDiskSpace() -> UInt64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory())
                .resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
                .volumeAvailableCapacityForImportantUsage {
                return UInt64(space)
            }
        } else {
            if let systemAttributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory()),
               let freeSpace = (systemAttributes[.systemFreeSize] as? NSNumber)?.uint64Value {
                return freeSpace
            }
        }
        return 0
    }
}
