import Foundation
import Combine
import Photos

protocol CompressingVideoViewModelProtocol: AnyObject {
    var progress: Float { get }
    var progressPercentage: String { get }
    var isCompressing: Bool { get }
    var errorMessage: String? { get }
    
    var progressPublisher: AnyPublisher<Float, Never> { get }
    var progressPercentagePublisher: AnyPublisher<String, Never> { get }
    var isCompressingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    var completionPublisher: AnyPublisher<URL, Never> { get }
    
    func startCompression()
    func cancelCompression()
}

final class CompressingVideoViewModel: CompressingVideoViewModelProtocol {
    @Published private(set) var progress: Float = 0.0
    @Published private(set) var isCompressing: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private var compressedVideoURL: URL?
    
    var progressPublisher: AnyPublisher<Float, Never> {
        $progress.eraseToAnyPublisher()
    }
    
    var progressPercentagePublisher: AnyPublisher<String, Never> {
        $progress
            .map { String(format: "%.0f%%", $0 * 100) }
            .eraseToAnyPublisher()
    }
    
    var isCompressingPublisher: AnyPublisher<Bool, Never> {
        $isCompressing.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
    
    var completionPublisher: AnyPublisher<URL, Never> {
        $compressedVideoURL
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    var progressPercentage: String {
        String(format: "%.0f%%", progress * 100)
    }
    
    private let videoAsset: PHAsset
    private let quality: VideoQuality
    private let compressionService: VideoCompressionServiceProtocol
    private var compressionTask: Task<Void, Never>?
    
    init(
        videoAsset: PHAsset,
        quality: VideoQuality,
        compressionService: VideoCompressionServiceProtocol = VideoCompressionService()
    ) {
        self.videoAsset = videoAsset
        self.quality = quality
        self.compressionService = compressionService
    }
    
    func startCompression() {
        guard !isCompressing else { return }
        
        isCompressing = true
        progress = 0.0
        errorMessage = nil
        
        compressionTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let outputURL = try await compressionService.compressVideo(
                    asset: videoAsset,
                    quality: quality
                ) { [weak self] progress in
                    Task { @MainActor [weak self] in
                        self?.progress = progress
                    }
                }
                
                await MainActor.run {
                    self.compressedVideoURL = outputURL
                    self.isCompressing = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isCompressing = false
                }
            }
        }
    }
    
    func cancelCompression() {
        compressionTask?.cancel()
        isCompressing = false
        progress = 0.0
    }
}
