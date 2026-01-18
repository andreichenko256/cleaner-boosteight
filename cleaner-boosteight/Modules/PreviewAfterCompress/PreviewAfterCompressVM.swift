import Foundation
import Combine
import Photos

protocol PreviewAfterCompressViewModelProtocol: AnyObject {
    var originalSize: String { get }
    var compressedSize: String { get }
    var compressedVideoURL: URL? { get }
    
    var compressedSizePublisher: AnyPublisher<String, Never> { get }
    var saveProgressPublisher: AnyPublisher<Bool, Never> { get }
    
    func loadCompressedVideoSize()
    func saveCompressedVideoToLibrary() async throws
    func deleteOriginalVideo() async throws
}

final class PreviewAfterCompressViewModel: PreviewAfterCompressViewModelProtocol {
    @Published private(set) var isVideoSaved: Bool = false
    @Published private(set) var compressedSize: String = "Calculating..."
    
    private(set) var compressedVideoURL: URL?
    private(set) var originalSize: String
    
    var compressedSizePublisher: AnyPublisher<String, Never> {
        $compressedSize.eraseToAnyPublisher()
    }
    
    var saveProgressPublisher: AnyPublisher<Bool, Never> {
        $isVideoSaved.eraseToAnyPublisher()
    }
    
    private let originalVideoAsset: PHAsset
    private let originalSizeBytes: UInt64
    
    init(
        originalVideoAsset: PHAsset,
        originalSizeBytes: UInt64,
        compressedVideoURL: URL
    ) {
        self.originalVideoAsset = originalVideoAsset
        self.originalSizeBytes = originalSizeBytes
        self.compressedVideoURL = compressedVideoURL
        self.originalSize = ByteSizeFormatter.format(originalSizeBytes)
    }
    
    func loadCompressedVideoSize() {
        guard let url = compressedVideoURL else { return }
        
        Task {
            let size = await getFileSize(at: url)
            await MainActor.run {
                compressedSize = ByteSizeFormatter.format(size)
            }
        }
    }
    
    func saveCompressedVideoToLibrary() async throws {
        guard let videoURL = compressedVideoURL else {
            throw VideoSaveError.invalidURL
        }
        
        guard FileManager.default.fileExists(atPath: videoURL.path) else {
            throw VideoSaveError.fileNotFound
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }
        
        await MainActor.run {
            isVideoSaved = true
            NotificationCenter.default.post(name: .mediaItemsUpdated, object: nil)
        }
    }
    
    func deleteOriginalVideo() async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets([self.originalVideoAsset] as NSArray)
        }
    }
}

private extension PreviewAfterCompressViewModel {
    func getFileSize(at url: URL) async -> UInt64 {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    let size = attributes[.size] as? UInt64 ?? 0
                    continuation.resume(returning: size)
                } catch {
                    continuation.resume(returning: 0)
                }
            }
        }
    }
}

enum VideoSaveError: LocalizedError {
    case invalidURL
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid video URL"
        case .fileNotFound:
            return "Compressed video file not found"
        }
    }
}
