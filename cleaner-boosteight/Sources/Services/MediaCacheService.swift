import Foundation

protocol MediaCacheServiceProtocol {
    func getCachedMediaInfo(for type: MediaCacheType) -> CachedMediaInfo?
    func saveMediaInfo(_ info: CachedMediaInfo, for type: MediaCacheType)
    func clearCache()
    func clearCache(for type: MediaCacheType)
}

enum MediaCacheType: String {
    case videos
    case allMedia
}

struct CachedMediaInfo: Codable {
    let count: Int
    let size: UInt64
    let timestamp: Date
}

final class MediaCacheService: MediaCacheServiceProtocol {
    
    private let userDefaults: UserDefaults
    private let cacheExpirationDays: Int
    
    init(
        userDefaults: UserDefaults = .standard,
        cacheExpirationDays: Int = 7
    ) {
        self.userDefaults = userDefaults
        self.cacheExpirationDays = cacheExpirationDays
    }
    
    func getCachedMediaInfo(for type: MediaCacheType) -> CachedMediaInfo? {
        guard let data = userDefaults.data(forKey: cacheKey(for: type)),
              let info = try? JSONDecoder().decode(CachedMediaInfo.self, from: data) else {
            return nil
        }
        
        if isCacheExpired(info.timestamp) {
            return nil
        }
        
        return info
    }
    
    func saveMediaInfo(_ info: CachedMediaInfo, for type: MediaCacheType) {
        guard let data = try? JSONEncoder().encode(info) else {
            return
        }
        userDefaults.set(data, forKey: cacheKey(for: type))
    }
    
    func clearCache() {
        MediaCacheType.allCases.forEach { type in
            userDefaults.removeObject(forKey: cacheKey(for: type))
        }
    }
    
    func clearCache(for type: MediaCacheType) {
        userDefaults.removeObject(forKey: cacheKey(for: type))
    }
    
    private func cacheKey(for type: MediaCacheType) -> String {
        return "media_cache_\(type.rawValue)"
    }
    
    private func isCacheExpired(_ timestamp: Date) -> Bool {
        let expirationDate = Calendar.current.date(
            byAdding: .day,
            value: cacheExpirationDays,
            to: timestamp
        ) ?? timestamp
        return Date() > expirationDate
    }
}

extension MediaCacheType: CaseIterable {}
