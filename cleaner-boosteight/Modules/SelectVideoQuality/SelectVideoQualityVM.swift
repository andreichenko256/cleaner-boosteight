import Foundation
import Combine
import AVFoundation
import Photos

protocol SelectVideoQualityViewModelProtocol: AnyObject {
    var player: AVPlayer? { get }
    var selectedQuality: VideoQuality { get }
    var isLoadingVideo: Bool { get }
    var errorMessage: String? { get }
    var currentSize: String { get }
    var estimatedSize: String { get }
    var videoAsset: PHAsset { get }
    var originalSize: UInt64 { get }
    
    var playerPublisher: AnyPublisher<AVPlayer?, Never> { get }
    var selectedQualityPublisher: AnyPublisher<VideoQuality, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }
    var currentSizePublisher: AnyPublisher<String, Never> { get }
    var estimatedSizePublisher: AnyPublisher<String, Never> { get }
    
    func loadVideo()
    func selectQuality(_ quality: VideoQuality)
    func cleanup()
}

final class SelectVideoQualityViewModel: SelectVideoQualityViewModelProtocol {
    var playerPublisher: AnyPublisher<AVPlayer?, Never> {
        $player.eraseToAnyPublisher()
    }
    
    var selectedQualityPublisher: AnyPublisher<VideoQuality, Never> {
        $selectedQuality.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoadingVideo.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
    
    var currentSizePublisher: AnyPublisher<String, Never> {
        $currentSize.eraseToAnyPublisher()
    }
    
    var estimatedSizePublisher: AnyPublisher<String, Never> {
        $estimatedSize.eraseToAnyPublisher()
    }
    
    var videoAsset: PHAsset {
        videoModel.asset
    }
    
    var originalSize: UInt64 {
        videoModel.size
    }
    
    @Published private(set) var player: AVPlayer?
    @Published private(set) var selectedQuality: VideoQuality = .medium
    @Published private(set) var isLoadingVideo: Bool = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var currentSize: String
    @Published private(set) var estimatedSize: String
    
    private var cancellables = Set<AnyCancellable>()
    
    private let videoModel: VideoModel

    init(videoModel: VideoModel) {
        self.videoModel = videoModel
        self.currentSize = ByteSizeFormatter.format(videoModel.size)
        self.estimatedSize = ByteSizeFormatter.format(Self.calculateEstimatedSize(original: videoModel.size, quality: .medium))
    }

    func loadVideo() {
        guard !isLoadingVideo else { return }
        
        isLoadingVideo = true
        errorMessage = nil
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestPlayerItem(
            forVideo: videoModel.asset,
            options: options
        ) { [weak self] playerItem, info in
            DispatchQueue.main.async {
                self?.handleVideoLoaded(playerItem: playerItem, info: info)
            }
        }
    }
    
    func selectQuality(_ quality: VideoQuality) {
        guard selectedQuality != quality else { return }
        selectedQuality = quality
        estimatedSize = ByteSizeFormatter.format(Self.calculateEstimatedSize(original: videoModel.size, quality: quality))
    }
    
    func cleanup() {
        player?.pause()
        player = nil
        cancellables.removeAll()
    }
}

private extension SelectVideoQualityViewModel {
    func handleVideoLoaded(playerItem: AVPlayerItem?, info: [AnyHashable: Any]?) {
        isLoadingVideo = false
        
        if let error = info?[PHImageErrorKey] as? Error {
            errorMessage = "Failed to load video: \(error.localizedDescription)"
            return
        }
        
        guard let playerItem = playerItem else {
            errorMessage = "Failed to load video"
            return
        }
        
        player = AVPlayer(playerItem: playerItem)
    }
    
    static func calculateEstimatedSize(original: UInt64, quality: VideoQuality) -> UInt64 {
        let compressionRatio: Double
        
        switch quality {
        case .low:
            compressionRatio = 0.35
        case .medium:
            compressionRatio = 0.55
        case .high:
            compressionRatio = 0.75
        }
        
        return UInt64(Double(original) * compressionRatio)
    }
}
