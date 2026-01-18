import Foundation
import AVFoundation
import Photos

protocol VideoCompressionServiceProtocol {
    func compressVideo(
        asset: PHAsset,
        quality: VideoQuality,
        progressHandler: @escaping (Float) -> Void
    ) async throws -> URL
}

final class VideoCompressionService: VideoCompressionServiceProtocol {
    private let imageManager: PHImageManager
    
    init(imageManager: PHImageManager = .default()) {
        self.imageManager = imageManager
    }
    
    func compressVideo(
        asset: PHAsset,
        quality: VideoQuality,
        progressHandler: @escaping (Float) -> Void
    ) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.version = .current
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            
            imageManager.requestAVAsset(
                forVideo: asset,
                options: options
            ) { [weak self] avAsset, _, _ in
                guard let self = self,
                      let avAsset = avAsset else {
                    continuation.resume(throwing: VideoCompressionError.failedToLoadAsset)
                    return
                }
                
                Task {
                    do {
                        let outputURL = try await self.compress(
                            asset: avAsset,
                            quality: quality,
                            progressHandler: progressHandler
                        )
                        continuation.resume(returning: outputURL)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}

private extension VideoCompressionService {
    func compress(
        asset: AVAsset,
        quality: VideoQuality,
        progressHandler: @escaping (Float) -> Void
    ) async throws -> URL {
        guard let exportSession = createExportSession(
            asset: asset,
            quality: quality
        ) else {
            throw VideoCompressionError.failedToCreateExportSession
        }
        
        let outputURL = createOutputURL()
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        return try await withCheckedThrowingContinuation { continuation in
            let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                progressHandler(exportSession.progress)
            }
            
            exportSession.exportAsynchronously {
                progressTimer.invalidate()
                
                switch exportSession.status {
                case .completed:
                    continuation.resume(returning: outputURL)
                case .failed:
                    let error = exportSession.error ?? VideoCompressionError.unknown
                    continuation.resume(throwing: error)
                case .cancelled:
                    continuation.resume(throwing: VideoCompressionError.cancelled)
                default:
                    continuation.resume(throwing: VideoCompressionError.unknown)
                }
            }
        }
    }
    
    func createExportSession(asset: AVAsset, quality: VideoQuality) -> AVAssetExportSession? {
        let preset = getPreset(for: quality)
        
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: preset
        ) else {
            return nil
        }
        
        return exportSession
    }
    
    func getPreset(for quality: VideoQuality) -> String {
        switch quality {
        case .low:
            return AVAssetExportPresetLowQuality
        case .medium:
            return AVAssetExportPresetMediumQuality
        case .high:
            return AVAssetExportPresetHighestQuality
        }
    }
    
    func createOutputURL() -> URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        
        let fileName = "compressed_video_\(UUID().uuidString).mp4"
        return documentsPath.appendingPathComponent(fileName)
    }
}

enum VideoCompressionError: LocalizedError {
    case failedToLoadAsset
    case failedToCreateExportSession
    case cancelled
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .failedToLoadAsset:
            return "Failed to load video asset"
        case .failedToCreateExportSession:
            return "Failed to create export session"
        case .cancelled:
            return "Compression was cancelled"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}
